//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Utilities
import HTTPTypes
import ServiceLifecycle
import Logging
import Foundation
import NIOCore

@freestanding(expression)
public macro router<T>(returnType: RouterReturnType, version: String, middleware: [Middleware], _ routes: Route...) -> Router<T> = #externalMacro(module: "Macros", type: "Router")


// MARK: Application
public struct Application : Service {
    public let services:[Service]
    public let logger:Logger

    public init(
        services: [Service] = [],
        logger: Logger
    ) {
        self.services = services
        self.logger = logger
    }
    public func run() async throws {
        let service_group:ServiceGroup = ServiceGroup(configuration: .init(services: services, logger: logger))
        let bro:Socket = Socket(fileDescriptor: 0)
        bro.close()
        try await service_group.run()
    }
}

func strerror() -> String { String(cString: strerror(errno)) }

// MARK: Server
public final class Server : Service {
    let address:String?
    let port:in_port_t
    let maxPendingConnections:Int32
    let logger:Logger

    public init(
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        logger: Logger
    ) {
        self.address = address
        self.port = port
        self.maxPendingConnections = maxPendingConnections
        self.logger = logger
    }

    public func run() async throws {
        let fileDescriptor:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
        if fileDescriptor == -1 {
            throw Server.Error.socketCreationFailed()
        }
        Socket.noSigPipe(fileDescriptor: fileDescriptor)
        var binded:Int32 = -1
        var addr = sockaddr_in6(
            sin6_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin6_family: UInt8(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        if let address:String = address {
            if address.withCString { inet_pton(AF_INET6, $0, &addr.sin6_addr) } == 1 {
            }
        }
        binded = withUnsafePointer(to: &addr) {
            bind(fileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
        }
        if binded == -1 {
            unistd.close(fileDescriptor)
            throw Server.Error.bindFailed()
        }
        if listen(fileDescriptor, maxPendingConnections) == -1 {
            unistd.close(fileDescriptor)
            throw Server.Error.listenFailed()
        }
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on port \(port)"))
        repeat {
            do {
                let client:Socket = try client(fileDescriptor: fileDescriptor)
                try client.write(StaticString("wtf"))
                logger.info(Logger.Message(stringLiteral: "accepted and processed client"))
            } catch {
                logger.error(Logger.Message.init(stringLiteral: "\(error)"))
            }
        } while !Task.isCancelled
    }

    func client(fileDescriptor: Int32) throws -> Socket {
        var addr:sockaddr = sockaddr(), len:socklen_t = 0
        let client:Int32 = accept(fileDescriptor, &addr, &len)
        if client <= 0 {
            throw Socket.Error.acceptFailed()
        }
        return Socket(fileDescriptor: client)
    }
}
// MARK: Server.Error
extension Server {
    enum Error : Swift.Error {
        case socketCreationFailed(String = strerror())
        case bindFailed(String = strerror())
        case listenFailed(String = strerror())
    }
}

// MARK: SocketProtocol
protocol SocketProtocol : ~Copyable {
    var fileDescriptor : Int32 { get }
    var closed : Bool { get set }
    consuming func close()
}

extension SocketProtocol where Self : ~Copyable {
    consuming func close() {
        guard !closed else { return }
        closed = true
        unistd.close(fileDescriptor)
    }

    func deinitalize() {
        guard !closed else { return }
        unistd.close(fileDescriptor)
    }
}

// MARK: Socket
struct Socket : SocketProtocol, ~Copyable {
    static func noSigPipe(fileDescriptor: Int32) {
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
    }
    static let bufferLength:Int = 1024
    let fileDescriptor:Int32
    var closed:Bool

    init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        closed = false
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    deinit { deinitalize() }
}
// MARK: Socket reading
extension Socket {
    func readHttpRequest() throws {
        let status:String = try readLine()
        let tokens:[Substring] = status.split(separator: " ")
        guard tokens.count >= 3 else {
            throw Socket.Error.invalidStatus()
        }
    }

    /// Reads 1 byte
    @inlinable
    func read() throws -> UInt8 {
        var result:UInt8 = 0
        unistd.read(fileDescriptor, &result, 1)
        guard result > 0 else { throw Socket.Error.readFailed() }
        return result
    }
    /// Reads and loads multiple bytes into an UInt8 array
    @inlinable
    func read(length: Int) throws -> [UInt8] {
        return try [UInt8](unsafeUninitializedCapacity: length, initializingWith: { $1 = try read(into: &$0, length: length) })
    }

    @inlinable
    func readLine() throws -> String {
        var line:String = ""
        var index:UInt8 = 0
        while index != 10 {
            index = try self.read()
            if index > 13 {
                line.append(Character(UnicodeScalar(index)))
            }
        }
        return line
    }

    /*
    /// Reads and loads multiple bytes into an UInt8 array
    @inlinable
    func read<T : Decodable>(decoder: Decoder) throws -> T {
        let length:Int = MemoryLayout<T>.size
        var buffer:UnsafeMutableBufferPointer<UInt8> = .allocate(capacity: length)
        try read(into: &buffer, length: length)
        return buffer.withUnsafeBytes {
            $0.withMemoryRebound(to: T.self, { _ in
                T.init(from: decoder)
            })
        }
    }*/

    /// Reads and writes multiple bytes into a buffer
    @inlinable
    func read(into buffer: inout UnsafeMutableBufferPointer<UInt8>, length: Int) throws -> Int {
        var bytes_read:Int = 0
        guard let baseAddress:UnsafeMutablePointer<UInt8> = buffer.baseAddress else { return 0 }
        while bytes_read < length {
            let to_read:Int = min(bytes_read + Self.bufferLength, length)
            let read_bytes:Int = unistd.read(fileDescriptor, baseAddress + bytes_read, to_read)
            guard read_bytes > 0 else {
                throw Socket.Error.readFailed()
            }
            bytes_read += read_bytes
        }
        return bytes_read
    }
}
// MARK: Socket writing
extension Socket {
    @inlinable
    func write(_ string: consuming String) throws {
        try string.withUTF8 {
            try write($0.baseAddress!, length: string.utf8.count)
        }
    }
    @inlinable
    func write(_ string: StaticString) throws {
        var errored:Bool = false
        string.withUTF8Buffer {
            if let _ = try? write($0.baseAddress!, length: $0.count) {
            } else {
                errored = true
            }
        }
        if errored {
            throw Socket.Error.writeFailed()
        }
    }
    @inlinable
    func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBufferPointer {
            try write($0.baseAddress!, length: bytes.count)
        }
    }
    @inlinable
    func write(_ bytes: ArraySlice<UInt8>) throws {
        try bytes.withUnsafeBufferPointer {
            try write($0.baseAddress!, length: $0.count)
        }
    }
    @inlinable
    func write(_ buffer: ByteBuffer) throws {
        try buffer.withUnsafeReadableBytes {
            try write($0.baseAddress!, length: buffer.readableBytes)
        }
    }
    @inlinable
    func write(_ data: Data) throws {
        try data.withUnsafeBytes {
            try write($0.baseAddress!, length: data.count)
        }
    }
    @inlinable
    func write(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent:Int = 0
        while sent < length {
            let result:Int = unistd.write(fileDescriptor, pointer + sent, length - sent)
            if result <= 0 { throw Socket.Error.writeFailed() }
            sent += 1
        }
    }
}
// MARK: Socket.Error
extension Socket {
    enum Error : Swift.Error {
        case acceptFailed(String = strerror())
        case writeFailed(String = strerror())
        case readFailed(String = strerror())
        case invalidStatus(String = strerror())
    }
}
//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import NIOCore

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
    func write(_ string: consuming String) throws {
        try string.withUTF8 {
            try write($0.baseAddress!, length: string.utf8.count)
        }
    }
    func write(_ string: StaticString) throws {
        var errored:Bool = false
        string.withUTF8Buffer {
            if let baseAddress:UnsafePointer<UInt8> = $0.baseAddress, let _ = try? write(baseAddress, length: $0.count) {
            } else {
                errored = true
            }
        }
        if errored {
            throw Socket.Error.writeFailed()
        }
    }
    func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBufferPointer {
            try write($0.baseAddress!, length: bytes.count)
        }
    }
    func write(_ bytes: ArraySlice<UInt8>) throws {
        try bytes.withUnsafeBufferPointer {
            try write($0.baseAddress!, length: $0.count)
        }
    }
    func write(_ buffer: ByteBuffer) throws {
        try buffer.withUnsafeReadableBytes {
            try write($0.baseAddress!, length: buffer.readableBytes)
        }
    }
    func write(_ data: Data) throws {
        try data.withUnsafeBytes {
            try write($0.baseAddress!, length: data.count)
        }
    }
    func write(_ pointer: UnsafeRawPointer, length: Int) throws {
        guard !closed else { return }
        var sent:Int = 0
        while sent < length {
            let result:Int = unistd.write(fileDescriptor, pointer + sent, length - sent)
            if result <= 0 { throw Socket.Error.writeFailed() }
            sent += result
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
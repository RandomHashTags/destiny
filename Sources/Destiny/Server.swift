//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import ServiceLifecycle
import Logging

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
            if address.withCString({ inet_pton(AF_INET6, $0, &addr.sin6_addr) }) == 1 {
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
        let response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:4\r\n\r\ntest")
        repeat {
            do {
                let client:Socket = try client(fileDescriptor: fileDescriptor)
                try client.write(response)
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
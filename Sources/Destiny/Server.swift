//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import ServiceLifecycle
import Logging
import Utilities

// MARK: Server
public final class Server : Service {
    let address:String?
    let port:in_port_t
    let maxPendingConnections:Int32
    let logger:Logger

    let routers:[Router]

    public init(
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        routers: [Router],
        logger: Logger
    ) {
        self.address = address
        self.port = port
        self.maxPendingConnections = maxPendingConnections
        self.routers = routers
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
        var staticResponses:[String:RouteResponseProtocol] = [:]
        for router in routers {
            for (path, responder) in router.staticResponses {
                staticResponses[String(path)] = responder
            }
        }
        let response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")
        repeat {
            do {
                let client:Socket = try client(fileDescriptor: fileDescriptor)
                let tokens:[Substring] = try client.readHttpRequest()
                if let responder:RouteResponseProtocol = staticResponses[tokens[0] + " " + tokens[1]] {
                    try responder.respond(to: consume client)
                } else {
                    var err:Swift.Error? = nil
                    response.withUTF8Buffer {
                        do {
                            try client.write($0.baseAddress!, length: $0.count)
                        } catch {
                            err = error
                        }
                    }
                    if let error:Swift.Error = err {
                        throw error
                    }
                }
            } catch {
                logger.error(Logger.Message.init(stringLiteral: "\(error)"))
            }
        } while !Task.isCancelled
    }

    func client(fileDescriptor: Int32) throws -> Socket {
        var addr:sockaddr = sockaddr(), len:socklen_t = 0
        let client:Int32 = accept(fileDescriptor, &addr, &len)
        if client <= 0 {
            throw SocketError.acceptFailed()
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
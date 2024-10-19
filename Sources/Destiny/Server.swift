//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import ServiceLifecycle
import Logging
import DestinyUtilities

// MARK: Server
public actor Server : Service {
    static var connections:[Int32:Task<(), Swift.Error>] = Dictionary(minimumCapacity: 50)

    let address:String?
    let port:in_port_t
    let maxPendingConnections:Int32
    let routers:[Router]
    let logger:Logger

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
        var addr:sockaddr_in6 = sockaddr_in6(
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
        let static_responses:[String:RouteResponseProtocol] = Self.static_responses(for: routers)
        let not_found_response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on port \(port)"))
        await withTaskCancellationOrGracefulShutdownHandler {
            while true {
                do {
                    let client:Int32 = try await Self.client(fileDescriptor: fileDescriptor)
                    let connection:Task<(), Swift.Error> = Task.detached {
                        let client_socket:Socket = Socket(fileDescriptor: client)
                        let tokens:[Substring] = try client_socket.readHttpRequest()
                        if let responder:RouteResponseProtocol = static_responses[tokens[0] + " " + tokens[1]] {
                            try await responder.respond(to: consume client_socket)
                        } else {
                            var err:Swift.Error? = nil
                            not_found_response.withUTF8Buffer {
                                do {
                                    try client_socket.write($0.baseAddress!, length: $0.count)
                                } catch {
                                    err = error
                                }
                            }
                            unistd.close(client)
                            if let error:Swift.Error = err {
                                throw error
                            }
                        }
                        Self.connections[client] = nil
                    }
                    Self.connections[client] = connection
                } catch {
                    logger.error(Logger.Message.init(stringLiteral: "\(error)"))
                }
            }
        } onCancelOrGracefulShutdown: {
            for (client, connection) in Self.connections {
                connection.cancel()
                unistd.close(client)
            }
            unistd.close(fileDescriptor)
        }
    }
    @inlinable
    static func static_responses(for routers: [Router]) -> [String:RouteResponseProtocol] {
        var responses:[String:RouteResponseProtocol] = [:]
        responses.reserveCapacity(routers.count)
        for router in routers {
            for (path, responder) in router.staticResponses {
                responses[String(path)] = responder
            }
        }
        return responses
    }

    static func client(fileDescriptor: Int32) async throws -> Int32 {
        return try await withCheckedThrowingContinuation { continuation in
            var addr:sockaddr = sockaddr(), len:socklen_t = 0
            let client:Int32 = accept(fileDescriptor, &addr, &len)
            if client <= 0 {
                continuation.resume(throwing: SocketError.acceptFailed())
                return
            }
            continuation.resume(returning: client)
        }
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
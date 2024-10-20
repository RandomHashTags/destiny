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
public final class Server : Service, DestinyClientAcceptor {
    public var connections:Set<Int32> = Set(minimumCapacity: 50)

    let threads:Int
    let address:String?
    let port:in_port_t
    let maxPendingConnections:Int32
    public var routers:[Router]
    let logger:Logger

    public init(
        threads: Int,
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        routers: [Router],
        logger: Logger
    ) {
        self.threads = threads
        self.address = address
        self.port = port
        self.maxPendingConnections = maxPendingConnections
        self.routers = routers
        self.logger = logger
    }

    public func run() async throws {
        let serverFD:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
        if serverFD == -1 {
            throw Server.Error.socketCreationFailed()
        }
        Socket.noSigPipe(fileDescriptor: serverFD)
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
        var binded:Int32 = -1
        binded = withUnsafePointer(to: &addr) {
            bind(serverFD, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
        }
        if binded == -1 {
            close(serverFD)
            throw Server.Error.bindFailed()
        }
        if listen(serverFD, maxPendingConnections) == -1 {
            close(serverFD)
            throw Server.Error.listenFailed()
        }
        let static_responses:[String:RouteResponseProtocol] = Self.static_responses(for: routers)
        let not_found_response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on port \(port)"))
        let queue:DispatchQueue = DispatchQueue(label: "destiny.dispatchQueue", qos: .userInitiated, attributes: .concurrent)
        await withTaskCancellationOrGracefulShutdownHandler {
            for _ in 0..<threads-1 {
                Thread.detachNewThread {
                    while !Task.isCancelled && !Task.isShuttingDownGracefully {
                        do {
                            let client:Int32 = try Server.client(fileDescriptor: serverFD)
                            queue.async { [weak self] in
                                do {
                                    try Self.process_client(client: client, static_responses: static_responses, not_found_response: not_found_response)
                                } catch {
                                    self?.logger.error(Logger.Message(stringLiteral: "\(error)"))
                                }
                            }
                        } catch {
                            self.logger.error(Logger.Message(stringLiteral: "\(error)"))
                        }
                    }
                }
            }
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                do {
                    let client:Int32 = try Server.client(fileDescriptor: serverFD)
                    queue.async { [weak self] in
                        do {
                            try Self.process_client(client: client, static_responses: static_responses, not_found_response: not_found_response)
                        } catch {
                            self?.logger.error(Logger.Message(stringLiteral: "\(error)"))
                        }
                    }
                } catch {
                    self.logger.error(Logger.Message(stringLiteral: "\(error)"))
                }
            }
        } onCancelOrGracefulShutdown: {
            close(serverFD)
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

    @inlinable
    static func client(fileDescriptor: Int32) throws -> Int32 {
        var addr:sockaddr = sockaddr(), len:socklen_t = 0
        let client:Int32 = accept(fileDescriptor, &addr, &len)
        if client <= 0 {
            throw SocketError.acceptFailed()
        }
        return client
    }

    @inlinable
    static func process_client(
        client: Int32,
        static_responses: [String:RouteResponseProtocol],
        not_found_response: StaticString
    ) throws {
        let client_socket:Socket = Socket(fileDescriptor: client)
        let tokens:[Substring] = try client_socket.readHttpRequest()
        if let responder:RouteResponseProtocol = static_responses[tokens[0] + " " + tokens[1]] {
            if responder.isAsync {
                //try await responder.respondAsync(to: consume client_socket)
            } else {
                try responder.respond(to: consume client_socket)
            }
        } else {
            var err:Swift.Error? = nil
            not_found_response.withUTF8Buffer {
                do {
                    try client_socket.writeBuffer($0.baseAddress!, length: $0.count)
                } catch {
                    err = error
                }
            }
            if let error:Swift.Error = err {
                throw error
            }
        }
    }
}
public protocol DestinyClientAcceptor : AnyObject {
    var connections : Set<Int32> { get set }
}
// MARK: Server.Error
extension Server {
    enum Error : Swift.Error {
        case socketCreationFailed(String = strerror())
        case bindFailed(String = strerror())
        case listenFailed(String = strerror())
    }
}
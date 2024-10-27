//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation
import Logging
import ServiceLifecycle

// MARK: Server
public final class Server : Service {
    public static var shared:Server! = nil

    let address:String?
    let port:in_port_t
    let maxPendingConnections:Int32
    let router:Router
    let logger:Logger

    public init(
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        router: Router,
        logger: Logger
    ) {
        self.address = address
        self.port = port
        self.maxPendingConnections = maxPendingConnections
        self.router = router
        self.logger = logger
        Self.shared = self
    }

    public func run() async throws {
        #if os(Linux)
        let serverFD:Int32 = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
        let serverFD:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
        #endif
        if serverFD == -1 {
            throw Server.Error.socketCreationFailed()
        }
        Socket.noSigPipe(fileDescriptor: serverFD)
        #if os(Linux)
        var addr:sockaddr_in6 = sockaddr_in6(
            sin6_family: sa_family_t(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #else
        var addr:sockaddr_in6 = sockaddr_in6(
            sin6_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin6_family: UInt8(AF_INET6),
            sin6_port: port.bigEndian,
            sin6_flowinfo: 0,
            sin6_addr: in6addr_any,
            sin6_scope_id: 0
        )
        #endif
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
        let static_responses:[StackString32:RouteResponseProtocol] = router.staticResponses
        let not_found_response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [maxPendingConnections=\(maxPendingConnections)]"))
        await withTaskCancellationOrGracefulShutdownHandler {
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<maxPendingConnections {
                        group.addTask {
                            do {
                                let client:Int32 = try Self.client(serverFD: serverFD)
                                // TODO: move the processing of clients to a dedicated detached Thread/Task (or different system core)
                                try Self.process_client(client: client, static_responses: static_responses, not_found_response: not_found_response)
                            } catch {
                                self.logger.error(Logger.Message(stringLiteral: "\(error)"))
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }
        } onCancelOrGracefulShutdown: {
            close(serverFD)
        }
    }

    @inlinable
    static func client(serverFD: Int32) throws -> Int32 {
        var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            throw SocketError.acceptFailed()
        }
        return client
    }

    @inlinable
    static func process_client(
        client: Int32,
        static_responses: [StackString32:RouteResponseProtocol],
        not_found_response: StaticString
    ) throws {
        defer { close(client) }
        let client_socket:Socket = Socket(fileDescriptor: client)
        let token:StackString32 = try client_socket.readLineStackString()
        //let headers:[String:String] = try client_socket.readHeaders()
        if let responder:RouteResponseProtocol = static_responses[token] {
            if responder.isAsync {
                //try await responder.respondAsync(to: client_socket)
            } else {
                try responder.respond(to: client_socket)
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
// MARK: Server.Error
extension Server {
    enum Error : Swift.Error {
        case socketCreationFailed(String = cerror())
        case bindFailed(String = cerror())
        case listenFailed(String = cerror())
    }
}
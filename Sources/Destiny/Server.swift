//
//  Server.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import Logging
import ServiceLifecycle

// MARK: Server
public actor Server<C : SocketProtocol & ~Copyable, R: RouterProtocol & ~Copyable> : ServerProtocol {
    public typealias ClientSocket = C
    public typealias ServerRouter = R

    public let address:String?
    public var port:in_port_t
    /// The maximum amount of pending connections this Server will accept at a time.
    /// This value is capped at the system's limit (`ulimit -n`).
    public var maxPendingConnections:Int32
    public var router:R
    public let logger:Logger
    public let onLoad:(@Sendable () -> Void)?
    public let onShutdown:(@Sendable () -> Void)?

    public init(
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        router: consuming R,
        logger: Logger,
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) {
        self.address = address
        self.port = port
        self.maxPendingConnections = min(SOMAXCONN, maxPendingConnections)
        self.router = router
        self.logger = logger
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }

    public func run() async throws {
        #if os(Linux)
        let serverFD:Int32 = socket(AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
        let serverFD:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
        #endif
        if serverFD == -1 {
            throw ServerError.socketCreationFailed()
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
            throw ServerError.bindFailed()
        }
        if listen(serverFD, maxPendingConnections) == -1 {
            close(serverFD)
            throw ServerError.listenFailed()
        }
        let not_found_response:StaticString = StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")
        let on_shutdown:(@Sendable () -> Void)? = onShutdown
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [maxPendingConnections=\(maxPendingConnections)]"))
        await withTaskCancellationOrGracefulShutdownHandler {
            onLoad?()
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<maxPendingConnections {
                        group.addTask {
                            do {
                                let client:Int32 = try Self.client(serverFD: serverFD)
                                // TODO: move the processing of clients to a dedicated detached Thread/Task (or different system core)
                                try await ClientProcessing.process_client(
                                    client: client,
                                    client_socket: ClientSocket(fileDescriptor: client),
                                    router: self.router,
                                    not_found_response: not_found_response
                                )
                            } catch {
                                self.logger.error(Logger.Message(stringLiteral: "\(error)"))
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }
        } onCancelOrGracefulShutdown: {
            on_shutdown?()
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
}
// MARK: Client Processing
enum ClientProcessing {
    @inlinable
    static func process_client<C: SocketProtocol & ~Copyable, R: RouterProtocol & ~Copyable>(
        client: Int32,
        client_socket: consuming C,
        router: borrowing R,
        not_found_response: borrowing StaticString
    ) async throws {
        defer {
            shutdown(client, 2) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
            close(client)
        }
        var request:Request = try client_socket.loadRequest()
        if let responder:StaticRouteResponderProtocol = router.staticResponder(for: request.startLine) {
            if responder.isAsync {
                try await responder.respondAsync(to: client_socket)
            } else {
                try responder.respond(to: client_socket)
            }
        } else if let responder:DynamicRouteResponderProtocol = router.dynamicResponder(for: &request) {
            var response:DynamicResponseProtocol = responder.defaultResponse
            for index in responder.parameterPathIndexes {
                response.parameters[responder.path[index].value] = request.path[index]
            }
            for middleware in router.dynamicMiddleware {
                if middleware.shouldHandle(request: &request, response: response) {
                    do {
                        if middleware.isAsync {
                            try await middleware.handleAsync(request: &request, response: &response)
                        } else {
                            try middleware.handle(request: &request, response: &response)
                        }
                    } catch {
                        if middleware.isAsync {
                            await middleware.onErrorAsync(request: &request, response: &response, error: error)
                        } else {
                            middleware.onError(request: &request, response: &response, error: error)
                        }
                        break
                    }
                }
            }
            if responder.isAsync {
                try await responder.respondAsync(to: client_socket, request: &request, response: &response)
            } else {
                try responder.respond(to: client_socket, request: &request, response: &response)
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
// MARK: ServerError
enum ServerError : Swift.Error {
    case socketCreationFailed(String = cerror())
    case bindFailed(String = cerror())
    case listenFailed(String = cerror())
}
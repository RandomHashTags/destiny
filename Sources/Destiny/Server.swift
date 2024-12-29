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
/// The default `ServerProtocol` implementation Destiny uses.
public struct Server<C : SocketProtocol & ~Copyable> : ServerProtocol {
    public typealias ClientSocket = C

    public let address:String?
    public var port:in_port_t
    /// The maximum amount of pending connections this Server will accept at a time.
    /// This value is capped at the system's limit (`ulimit -n`).
    public var maxPendingConnections:Int32
    public let router:RouterProtocol
    public let logger:Logger
    public let onLoad:(@Sendable () -> Void)?
    public let onShutdown:(@Sendable () -> Void)?

    public init(
        address: String? = nil,
        port: in_port_t,
        maxPendingConnections: Int32 = SOMAXCONN,
        router: consuming RouterProtocol,
        logger: Logger,
        onLoad: (@Sendable () -> Void)? = nil,
        onShutdown: (@Sendable () -> Void)? = nil
    ) {
        var address:String? = address
        var port:in_port_t = port
        var maxPendingConnections:Int32 = maxPendingConnections
        var option:Int = 0
        for (index, argument) in CommandLine.arguments.enumerated() {
            if index != 0 && index % 2 == 0 {
                switch option {
                case 0: address = argument
                case 1: port = UInt16(argument) ?? port
                case 2: maxPendingConnections = Int32(argument) ?? maxPendingConnections
                default: break
                }
            } else {
                switch argument {
                case "--hostname", "-h": option = 0
                case "--port", "-p": option = 1
                case "--maxpendingconnections", "-mpc": option = 2
                default: option = -1
                }
            }
        }
        self.address = address
        self.port = port
        self.maxPendingConnections = min(SOMAXCONN, maxPendingConnections)
        self.router = router
        self.logger = logger
        self.onLoad = onLoad
        self.onShutdown = onShutdown
    }
    
    // MARK: Run
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
        let on_shutdown:(@Sendable () -> Void)? = onShutdown
        logger.notice(Logger.Message(stringLiteral: "Listening for clients on http://\(address ?? "localhost"):\(port) [maxPendingConnections=\(maxPendingConnections)]"))
        await withTaskCancellationOrGracefulShutdownHandler {
            onLoad?()
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<maxPendingConnections {
                        group.addTask {
                            do {
                                let client:Int32 = try await Self.client(serverFD: serverFD)
                                try await ClientProcessing.process_client(
                                    client: client,
                                    socket: ClientSocket(fileDescriptor: client),
                                    logger: logger,
                                    router: router
                                )
                            } catch {
                                self.logger.warning(Logger.Message(stringLiteral: "\(error)"))
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

    // MARK: Shutdown
    public func shutdown() async throws {
        try await gracefulShutdown()
    }

    // MARK: Accept client
    @inlinable
    static func client(serverFD: Int32) async throws -> Int32 {
        return try await withCheckedThrowingContinuation { continuation in
            var addr:sockaddr_in = sockaddr_in(), len:socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
            let client:Int32 = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
            if client == -1 {
                continuation.resume(throwing: SocketError.acceptFailed())
                return
            }
            continuation.resume(returning: client)
        }
    }
}
// MARK: Client Processing
enum ClientProcessing {
    @inlinable
    static func process_client<C: SocketProtocol & ~Copyable>(
        client: Int32,
        socket: borrowing C,
        logger: Logger,
        router: borrowing RouterProtocol
    ) async throws {
        defer {
            shutdown(client, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
            close(client)
        }
        var request:RequestProtocol = try socket.loadRequest()
        #if DEBUG
        logger.info(Logger.Message(stringLiteral: request.startLine.stringSIMD()))
        #endif
        do {
            if try await !respond(socket: socket, request: &request, router: router) {
                try await router.notFoundResponse(socket: socket, request: &request)
            }
        } catch {
            await router.errorResponder(for: &request).respond(to: socket, with: error, for: &request, logger: logger)
        }
    }

    @inlinable
    static func respond<C: SocketProtocol & ~Copyable>(
        socket: borrowing C,
        request: inout RequestProtocol,
        router: borrowing RouterProtocol
    ) async throws -> Bool {
        if let responder:StaticRouteResponderProtocol = router.staticResponder(for: request.startLine) {
            try await staticResponse(socket: socket, responder: responder)
        } else if let responder:DynamicRouteResponderProtocol = router.dynamicResponder(for: &request) {
            try await dynamicResponse(socket: socket, router: router, request: &request, responder: responder)
        } else if let responder:RouteResponderProtocol = router.conditionalResponder(for: &request) {
            if let staticResponder:StaticRouteResponderProtocol = responder as? StaticRouteResponderProtocol {
                try await staticResponse(socket: socket, responder: staticResponder)
            } else if let responder:DynamicRouteResponderProtocol = responder as? DynamicRouteResponderProtocol {
                try await dynamicResponse(socket: socket, router: router, request: &request, responder: responder)
            }
        } else {
            for group in router.routerGroups {
                if let responder:StaticRouteResponderProtocol = group.staticResponder(for: request.startLine) {
                    try await staticResponse(socket: socket, responder: responder)
                    return true
                } else if let responder:DynamicRouteResponderProtocol = group.dynamicResponder(for: &request) {
                    try await dynamicResponse(socket: socket, router: router, request: &request, responder: responder)
                    return true
                }
            }
            return false
        }
        return true
    }

    @inlinable
    static func staticResponse<C: SocketProtocol & ~Copyable>(
        socket: borrowing C,
        responder: StaticRouteResponderProtocol
    ) async throws {
        try await responder.respond(to: socket)
    }

    @inlinable
    static func dynamicResponse<C: SocketProtocol & ~Copyable>(
        socket: borrowing C,
        router: borrowing RouterProtocol,
        request: inout RequestProtocol,
        responder: DynamicRouteResponderProtocol
    ) async throws {
        var response:DynamicResponseProtocol = responder.defaultResponse
        for index in responder.parameterPathIndexes {
            response.parameters[responder.path[index].value] = request.path[index]
        }
        for middleware in router.dynamicMiddleware {
            try await middleware.handle(request: &request, response: &response)
        }
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}
// MARK: ServerError
enum ServerError : Swift.Error {
    case socketCreationFailed(String = cerror())
    case bindFailed(String = cerror())
    case listenFailed(String = cerror())
}
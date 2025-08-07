
import DestinyBlueprint
import Logging

#if canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#endif

/// Default HTTP Router implementation that optimally handles immutable and mutable middleware, routes and route groups.
public final class CompiledHTTPRouter<
        ImmutableRouter: HTTPRouterProtocol,
        MutableRouter: HTTPMutableRouterProtocol
    >: HTTPMutableRouterProtocol {
    public let immutable:ImmutableRouter
    public let mutable:MutableRouter
    
    public init(
        immutable: ImmutableRouter,
        mutable: MutableRouter
    ) {
        self.immutable = immutable
        self.mutable = mutable
    }
}

// MARK: Dynamic middleware
extension CompiledHTTPRouter {
    @inlinable
    public func load() throws(RouterError) {
        try immutable.load()
        try mutable.load()
    }

    @inlinable
    public func handleDynamicMiddleware(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) async throws(ResponderError) {
        try await immutable.handleDynamicMiddleware(for: &request, with: &response)
        try await mutable.handleDynamicMiddleware(for: &request, with: &response)
    }
}

// MARK: Handle
extension CompiledHTTPRouter {
    @inlinable
    public func handle(
        client: Int32,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        logger: Logger
    ) {
        Task {
            defer {
                #if canImport(SwiftGlibc) || canImport(Foundation)
                shutdown(client, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
                close(client)
                #else
                #warning("Unable to shutdown and close client file descriptor!")
                #endif
            }
            do throws(SocketError) {
                var request = try socket.loadRequest()
                #if DEBUG
                logger.info("\(request.startLine.stringSIMD())")
                #endif
                do throws(ResponderError) {
                    if !(try await respond(client: client, socket: socket, request: &request, logger: logger)) {
                        // TODO: not found
                    }
                } catch {
                    logger.warning("Encountered error while processing client: \(error)")
                }
            } catch {
                logger.warning("Encountered error while loading request: \(error)")
            }
        }
    }
}

// MARK: Respond
extension CompiledHTTPRouter {
    @inlinable
    public func respond(
        client: Int32,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) async throws(ResponderError) -> Bool {
        if try await immutable.respond(client: client, socket: socket, request: &request, logger: logger) {
            return true
        }
        if try await mutable.respond(client: client, socket: socket, request: &request, logger: logger) {
            return true
        }
        return false
    }
}

// MARK: Register
extension CompiledHTTPRouter {
    @inlinable
    public func register(
        caseSensitive: Bool,
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    ) {
        mutable.register(caseSensitive: caseSensitive, path: path, responder: responder)
    }

    @inlinable
    public func register(
        caseSensitive: Bool,
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    ) {
        mutable.register(caseSensitive: caseSensitive, route: route, responder: responder, override: override)
    }
}
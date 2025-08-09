
import DestinyBlueprint
import Logging

/// Default HTTP Router implementation that optimally handles immutable and mutable middleware, routes and route groups.
public final class CompiledHTTPRouter<
        ImmutableRouter: DestinyHTTPRouterProtocol,
        MutableRouter: DestinyHTTPMutableRouterProtocol
    >: DestinyHTTPMutableRouterProtocol {
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
    ) throws(ResponderError) {
        try immutable.handleDynamicMiddleware(for: &request, with: &response)
        try mutable.handleDynamicMiddleware(for: &request, with: &response)
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
        do throws(SocketError) {
            var request = try socket.loadRequest()
            #if DEBUG
            logger.info("\(request.startLine.stringSIMD())")
            #endif
            do throws(ResponderError) {
                guard !(try respond(socket: client, request: &request, logger: logger)) else { return }
                if !(try respondWithNotFound(socket: client, request: &request, logger: logger)) {
                    client.socketClose()
                }
            } catch {
                logger.warning("Encountered error while processing client: \(error)")
                if !respondWithError(socket: client, error: error, request: &request, logger: logger) {
                    client.socketClose()
                }
            }
        } catch {
            logger.warning("Encountered error while loading request: \(error)")
            client.socketClose()
        }
    }
}

// MARK: Respond
extension CompiledHTTPRouter {
    @inlinable
    public func respond(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) throws(ResponderError) -> Bool {
        if try immutable.respond(socket: socket, request: &request, logger: logger) {
            return true
        }
        if try mutable.respond(socket: socket, request: &request, logger: logger) {
            return true
        }
        return false
    }

    @inlinable
    public func respondWithNotFound(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) throws(ResponderError) -> Bool {
        if try mutable.respondWithNotFound(socket: socket, request: &request, logger: logger) {
        } else if try immutable.respondWithNotFound(socket: socket, request: &request, logger: logger) {
        } else {
            return false
        }
        return true
    }

    @inlinable
    public func respondWithError(
        socket: Int32,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) -> Bool {
        if mutable.respondWithError(socket: socket, error: error, request: &request, logger: logger) {
        } else if immutable.respondWithError(socket: socket, error: error, request: &request, logger: logger) {
        } else {
            return false
        }
        return true
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
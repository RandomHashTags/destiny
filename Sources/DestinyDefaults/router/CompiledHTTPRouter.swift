
import DestinyBlueprint
import Logging

/// Default HTTP Router implementation that optimally handles immutable and mutable middleware, routes and route groups.
public final class CompiledHTTPRouter<
        ImmutableRouter: DestinyHTTPRouterProtocol,
        MutableRouter: DestinyHTTPMutableRouterProtocol
    >: DestinyHTTPMutableRouterProtocol {
    public let immutable:ImmutableRouter
    public let mutable:MutableRouter

    public let logger:Logger
    
    public init(
        immutable: ImmutableRouter,
        mutable: MutableRouter
    ) {
        self.immutable = immutable
        self.mutable = mutable
        logger = Logger(label: "compiledHTTPRouter.destinydefaults")
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
    ) throws(MiddlewareError) {
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
        completionHandler: @Sendable @escaping () -> Void
    ) {
        do throws(SocketError) {
            var request = try socket.loadRequest()
            #if DEBUG
            logger.info("\(request.startLine.stringSIMD())")
            #endif
            do throws(ResponderError) {
                guard !(try respond(socket: client, request: &request, completionHandler: completionHandler)) else { return }
                if !(try respondWithNotFound(socket: client, request: &request, completionHandler: completionHandler)) {
                    completionHandler()
                }
            } catch {
                logger.warning("Encountered error while processing client: \(error)")
                if !respondWithError(socket: client, error: error, request: &request, completionHandler: completionHandler) {
                    completionHandler()
                }
            }
        } catch {
            logger.warning("Encountered error while loading request: \(error)")
            completionHandler()
        }
    }
}

// MARK: Respond
extension CompiledHTTPRouter {
    @inlinable
    public func respond(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try immutable.respond(socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try mutable.respond(socket: socket, request: &request, completionHandler: completionHandler) {
        } else {
            return false
        }
        return true
    }

    @inlinable
    public func respondWithNotFound(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try mutable.respondWithNotFound(socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try immutable.respondWithNotFound(socket: socket, request: &request, completionHandler: completionHandler) {
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
        completionHandler: @Sendable @escaping () -> Void
    ) -> Bool {
        if mutable.respondWithError(socket: socket, error: error, request: &request, completionHandler: completionHandler) {
        } else if immutable.respondWithError(socket: socket, error: error, request: &request, completionHandler: completionHandler) {
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

import DestinyBlueprint
import Logging

/// Default HTTP Router implementation that handles immutable middleware, routes and router groups.
public struct ImmutableHTTPRouter<
        CaseSensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        CaseInsensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        OpaqueDynamicMiddlewareStorage: OpaqueDynamicMiddlewareStorageProtocol,
        RouteGroupStorage: RouteGroupStorageProtocol,
        ErrorResponder: ErrorResponderProtocol,
        DynamicNotFoundResponder: DynamicRouteResponderProtocol,
        StaticNotFoundResponder: StaticRouteResponderProtocol
    >: DestinyHTTPRouterProtocol {
    public let caseSensitiveResponders:CaseSensitiveRouterResponderStorage
    public let caseInsensitiveResponders:CaseInsensitiveRouterResponderStorage

    public let opaqueDynamicMiddleware:OpaqueDynamicMiddlewareStorage

    public let routeGroups:RouteGroupStorage

    public let errorResponder:ErrorResponder?
    public let dynamicNotFoundResponder:DynamicNotFoundResponder?
    public let staticNotFoundResponder:StaticNotFoundResponder?

    public let logger:Logger
    
    public init(
        errorResponder: ErrorResponder?,
        dynamicNotFoundResponder: DynamicNotFoundResponder?,
        staticNotFoundResponder: StaticNotFoundResponder?,
        caseSensitiveResponders: CaseSensitiveRouterResponderStorage,
        caseInsensitiveResponders: CaseInsensitiveRouterResponderStorage,
        opaqueDynamicMiddleware: OpaqueDynamicMiddlewareStorage,
        routeGroups: RouteGroupStorage
    ) {
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.caseSensitiveResponders = caseSensitiveResponders
        self.caseInsensitiveResponders = caseInsensitiveResponders
        self.opaqueDynamicMiddleware = opaqueDynamicMiddleware
        self.routeGroups = routeGroups
        logger = Logger(label: "immutableHTTPRouter.destinydefaults")
    }

    @inlinable
    public func load() {
        /*for i in opaqueDynamicMiddleware.indices {
            opaqueDynamicMiddleware[i].load()
        }*/ // TODO: fix?
    }
}

// MARK: Dynamic middleware
extension ImmutableHTTPRouter {
    @inlinable
    public func handleDynamicMiddleware(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) {
        try opaqueDynamicMiddleware.handle(for: &request, with: &response)
    }
}

// MARK: Handle
extension ImmutableHTTPRouter {
    @inlinable
    public func handle(
        client: Int32,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) {
        do throws(SocketError) {
            var request = try socket.loadRequest()
            #if DEBUG
            let requestStartLine = try request.startLine().stringSIMD()
            logger.info("\(requestStartLine)")
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
extension ImmutableHTTPRouter {
    @inlinable
    public func respond(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try caseSensitiveResponders.respondStatically(router: self, socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try caseInsensitiveResponders.respondStatically(router: self, socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try caseSensitiveResponders.respondDynamically(router: self, socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try caseInsensitiveResponders.respondDynamically(router: self, socket: socket, request: &request, completionHandler: completionHandler) { // TODO: support
        } else if try routeGroups.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler) {
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
        if let dynamicNotFoundResponder {
            var response = try defaultDynamicResponse(request: &request, responder: dynamicNotFoundResponder)
            try dynamicNotFoundResponder.respond(router: self, socket: socket, request: &request, response: &response, completionHandler: completionHandler)
        } else if let staticNotFoundResponder {
            do throws(SocketError) {
                try staticNotFoundResponder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)
            } catch {
                throw .socketError(error)
            }
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
        guard let errorResponder else { return false }
        errorResponder.respond(router: self, socket: socket, error: error, request: &request, logger: logger, completionHandler: completionHandler)
        return true
    }
}

import DestinyBlueprint
import Logging

/// Default HTTP Router implementation that handles immutable middleware, routes and router groups.
public struct ImmutableHTTPRouter<
        CaseSensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        CaseInsensitiveRouterResponderStorage: RouterResponderStorageProtocol,
        RouteGroupStorage: RouteGroupStorageProtocol,
        ErrorResponder: ErrorResponderProtocol,
        DynamicNotFoundResponder: DynamicRouteResponderProtocol,
        StaticNotFoundResponder: StaticRouteResponderProtocol
    >: DestinyHTTPRouterProtocol {
    public let caseSensitiveResponders:CaseSensitiveRouterResponderStorage
    public let caseInsensitiveResponders:CaseInsensitiveRouterResponderStorage

    public let opaqueDynamicMiddleware:[any OpaqueDynamicMiddlewareProtocol]

    public let routeGroups:RouteGroupStorage

    public let errorResponder:ErrorResponder?
    public let dynamicNotFoundResponder:DynamicNotFoundResponder?
    public let staticNotFoundResponder:StaticNotFoundResponder?
    
    public init(
        errorResponder: ErrorResponder?,
        dynamicNotFoundResponder: DynamicNotFoundResponder?,
        staticNotFoundResponder: StaticNotFoundResponder?,
        caseSensitiveResponders: CaseSensitiveRouterResponderStorage,
        caseInsensitiveResponders: CaseInsensitiveRouterResponderStorage,
        opaqueDynamicMiddleware: [any OpaqueDynamicMiddlewareProtocol],
        routeGroups: RouteGroupStorage
    ) {
        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        self.caseSensitiveResponders = caseSensitiveResponders
        self.caseInsensitiveResponders = caseInsensitiveResponders
        self.opaqueDynamicMiddleware = opaqueDynamicMiddleware
        self.routeGroups = routeGroups
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
    ) throws(ResponderError) {
        for middleware in opaqueDynamicMiddleware {
            do throws(MiddlewareError) {
                if try !middleware.handle(request: &request, response: &response) {
                    break
                }
            } catch {
                throw .middlewareError(error)
            }
        }
    }
}

// MARK: Handle
extension ImmutableHTTPRouter {
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
extension ImmutableHTTPRouter {
    @inlinable
    public func respond(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) throws(ResponderError) -> Bool {
        if try caseSensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLine) {
        } else if try caseInsensitiveResponders.respondStatically(router: self, socket: socket, startLine: request.startLineLowercased()) {
        } else if try caseSensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) {
        } else if try caseInsensitiveResponders.respondDynamically(router: self, socket: socket, request: &request) { // TODO: support
        } else {
            return try routeGroups.respond(router: self, socket: socket, request: &request)
        }
        return true
    }

    @inlinable
    public func respondWithNotFound(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) throws(ResponderError) -> Bool {
        if let dynamicNotFoundResponder {
            var response = try defaultDynamicResponse(request: &request, responder: dynamicNotFoundResponder)
            try dynamicNotFoundResponder.respond(to: socket, request: &request, response: &response)
        } else if let staticNotFoundResponder {
            do throws(SocketError) {
                try staticNotFoundResponder.write(to: socket)
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
        logger: Logger
    ) -> Bool {
        guard let errorResponder else { return false }
        errorResponder.respond(socket: socket, error: error, request: &request, logger: logger)
        return true
    }
}
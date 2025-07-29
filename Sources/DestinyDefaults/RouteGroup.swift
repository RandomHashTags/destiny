
import DestinyBlueprint

// MARK: RouteGroup
/// Default mutable Route Group implementation that handles grouped routes.
public struct RouteGroup: RouteGroupProtocol {
    public let prefixEndpoints:[String]
    public let staticMiddleware:[any StaticMiddlewareProtocol]
    public let dynamicMiddleware:[any DynamicMiddlewareProtocol]
    public let staticResponses:StaticResponderStorage
    public let dynamicResponses:DynamicResponderStorage

    /*public init(
        endpoint: String,
        staticMiddleware: [any StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [any DynamicMiddlewareProtocol] = [],
        _ routes: any RouteProtocol...
    ) {
        var staticRoutes = [any StaticRouteProtocol]()
        var dynamicRoutes = [any DynamicRouteProtocol]()
        for route in routes {
            if let route = route as? any StaticRouteProtocol {
                staticRoutes.append(route)
            } else if let route = route as? any DynamicRouteProtocol {
                dynamicRoutes.append(route)
            }
        }
        self.init(endpoint: endpoint, staticMiddleware: staticMiddleware, dynamicMiddleware: dynamicMiddleware, staticRoutes: staticRoutes, dynamicRoutes: dynamicRoutes)
    }
    public init(
        endpoint: String,
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        staticRoutes: [any StaticRouteProtocol],
        dynamicRoutes: [any DynamicRouteProtocol]
    ) {
        let prefixEndpoints = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        var staticResponses = StaticResponderStorage()
        for var route in staticRoutes {
            route.insertPath(contentsOf: prefixEndpoints, at: 0)
            do {
                if let responder = try route.responder(middleware: staticMiddleware) {
                    staticResponses.register(path: DestinyRoutePathType(route.startLine), responder)
                }
            } catch {
                // TODO: do something
            }
        }

        let pathComponents = prefixEndpoints.map({ PathComponent.literal($0) })
        var parameterless = [DestinyRoutePathType:any DynamicRouteResponderProtocol]()
        var parameterized = [[any DynamicRouteResponderProtocol]]()
        for var route in dynamicRoutes {
            route.path.insert(contentsOf: pathComponents, at: 0)
            let responder = route.responder()
            if route.path.count(where: { $0.isParameter }) != 0 {
                if parameterized.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized.count) {
                        parameterized.append([])
                    }
                }
                parameterized[route.path.count].append(responder)
            } else {
                parameterless[DestinyRoutePathType(route.startLine())] = responder
            }
        }
        self.staticResponses = staticResponses
        self.dynamicResponses = .init(parameterless: parameterless, parameterized: parameterized, catchall: []) // TODO: fix catchall
    }*/
    public init(
        prefixEndpoints: [String],
        staticMiddleware: [any StaticMiddlewareProtocol],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        staticResponses: StaticResponderStorage,
        dynamicResponses: DynamicResponderStorage
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        self.staticResponses = staticResponses
        self.dynamicResponses = dynamicResponses
    }
}

// MARK: Respond
extension RouteGroup {
    @inlinable
    public func respond<Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool {
        if try await staticResponses.respond(router: router, socket: socket, startLine: request.startLine) {
            return true
        } else if let responder = dynamicResponses.responder(for: &request) {
            try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
            return true
        } else {
            return false
        }
    }
}
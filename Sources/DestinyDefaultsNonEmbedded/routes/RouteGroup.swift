
import DestinyBlueprint
import DestinyDefaults

// MARK: RouteGroup
/// Default mutable Route Group implementation that handles grouped routes.
public struct RouteGroup: RouteGroupProtocol { // TODO: avoid existentials / support embedded
    public let prefixEndpoints:[String]
    public let staticMiddleware:[any StaticMiddlewareProtocol]
    public let dynamicMiddleware:[any DynamicMiddlewareProtocol]
    public let staticResponses:StaticResponderStorage
    public let dynamicResponses:DynamicResponderStorage

    public init(
        endpoint: String,
        staticMiddleware: [any StaticMiddlewareProtocol] = [],
        dynamicMiddleware: [any DynamicMiddlewareProtocol] = [],
        _ routes: any RouteProtocol...
    ) {
        let prefixEndpoints = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.staticMiddleware = staticMiddleware
        self.dynamicMiddleware = dynamicMiddleware
        staticResponses = .init()
        dynamicResponses = .init()
    }
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
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try staticResponses.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        } else if let responder = try dynamicResponses.responder(for: &request) {
            try router.respond(socket: socket, request: &request, responder: responder, completionHandler: completionHandler)
            return true
        } else {
            return false
        }
    }
}
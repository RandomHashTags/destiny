
#if Copyable && MutableRouter

import DestinyBlueprint
import DestinyDefaults

// MARK: RouteGroup
/// Default mutable Route Group implementation that handles grouped routes.
public struct RouteGroup { // TODO: avoid existentials / support embedded
    public let prefixEndpoints:[String]

    #if StaticMiddleware
    public let staticMiddleware:[any StaticMiddlewareProtocol]
    #endif

    public let dynamicMiddleware:[any DynamicMiddlewareProtocol]
    public let staticResponses:StaticResponderStorage
    public let dynamicResponses:DynamicResponderStorage

    public init(
        endpoint: String,
        dynamicMiddleware: [any DynamicMiddlewareProtocol] = [],
        _ routes: any RouteProtocol...
    ) {
        let prefixEndpoints = endpoint.split(separator: "/").map({ String($0) })
        self.prefixEndpoints = prefixEndpoints
        self.dynamicMiddleware = dynamicMiddleware
        staticResponses = .init()
        dynamicResponses = .init()
    }
    public init(
        prefixEndpoints: [String],
        dynamicMiddleware: [any DynamicMiddlewareProtocol],
        staticResponses: StaticResponderStorage,
        dynamicResponses: DynamicResponderStorage
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.dynamicMiddleware = dynamicMiddleware
        self.staticResponses = staticResponses
        self.dynamicResponses = dynamicResponses
    }
}

#if StaticMiddleware

extension RouteGroup {
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

#endif

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
        } else if let responder = try dynamicResponses.responder(for: &request) {
            try router.respond(socket: socket, request: &request, responder: responder, completionHandler: completionHandler)
        } else {
            return false
        }
        return true
    }
}

// MARK: Conformances
extension RouteGroup: RouteGroupProtocol {}

#endif
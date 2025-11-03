
#if GenericRouteGroup

/// Default immutable Route Group implementation that handles grouped routes.
public struct GenericRouteGroup<
        DynamicMiddlewareStorage: DynamicMiddlewareStorageProtocol,
        StaticResponders: ResponderStorageProtocol,
        DynamicResponders: ResponderStorageProtocol
    >: Sendable, ~Copyable {
    public let dynamicMiddleware:DynamicMiddlewareStorage?
    public let staticResponders:StaticResponders
    public let dynamicResponders:DynamicResponders

    public init(
        dynamicMiddleware: DynamicMiddlewareStorage?,
        staticResponders: StaticResponders,
        dynamicResponders: DynamicResponders
    ) {
        self.dynamicMiddleware = dynamicMiddleware
        self.staticResponders = staticResponders
        self.dynamicResponders = dynamicResponders
    }
}

// MARK: Respond
extension GenericRouteGroup {
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest
    ) throws(DestinyError) -> Bool {
        if try staticResponders.respond(router: router, socket: socket, request: &request) {
        } else if try dynamicResponders.respond(router: router, socket: socket, request: &request) {
        } else {
            return false
        }
        return true
    }
}

#if Protocols

// MARK: Conformances
extension GenericRouteGroup: ResponderStorageProtocol {}

#endif

#endif
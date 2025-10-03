
#if GenericRouteGroup

import DestinyEmbedded

/// Default immutable Route Group implementation that handles grouped routes.
public struct GenericRouteGroup<
        DynamicMiddlewareStorage: DynamicMiddlewareStorageProtocol,
        StaticResponders: ResponderStorageProtocol,
        DynamicResponders: ResponderStorageProtocol
    >: ~Copyable {
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
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try staticResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try dynamicResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
        } else {
            return false
        }
        return true
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension GenericRouteGroup: RouteGroupProtocol {}

#endif

#endif
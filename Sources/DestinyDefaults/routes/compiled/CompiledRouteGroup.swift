
import DestinyBlueprint

/// Default immutable Route Group implementation that handles grouped routes.
public struct CompiledRouteGroup<
        let prefixEndpointsCount: Int,
        ImmutableDynamicMiddlewareStorage: DynamicMiddlewareStorageProtocol,
        ImmutableStaticResponders: StaticResponderStorageProtocol,
        ImmutableDynamicResponders: DynamicResponderStorageProtocol,
        MutableStaticResponders: MutableStaticResponderStorageProtocol,
        MutableDynamicResponders: MutableDynamicResponderStorageProtocol
    >: RouteGroupProtocol {
    public let prefixEndpoints:InlineArray<prefixEndpointsCount, String>
    public let immutableDynamicMiddleware:ImmutableDynamicMiddlewareStorage?

    public let immutableStaticResponders:ImmutableStaticResponders
    public let immutableDynamicResponders:ImmutableDynamicResponders

    public let mutableStaticResponders:MutableStaticResponders
    public let mutableDynamicResponders:MutableDynamicResponders

    public init(
        prefixEndpoints: InlineArray<prefixEndpointsCount, String>,
        immutableDynamicMiddleware: ImmutableDynamicMiddlewareStorage?,
        immutableStaticResponders: ImmutableStaticResponders,
        immutableDynamicResponders: ImmutableDynamicResponders,
        mutableStaticResponders: MutableStaticResponders,
        mutableDynamicResponders: MutableDynamicResponders
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.immutableDynamicMiddleware = immutableDynamicMiddleware
        self.immutableStaticResponders = immutableStaticResponders
        self.immutableDynamicResponders = immutableDynamicResponders
        self.mutableStaticResponders = mutableStaticResponders
        self.mutableDynamicResponders = mutableDynamicResponders
    }
}

// MARK: Respond
extension CompiledRouteGroup {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try immutableStaticResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        } else if try mutableStaticResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        } else if try immutableDynamicResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        } else if try mutableDynamicResponders.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        } else {
            return false
        }
    }
}

import DestinyBlueprint

/// Default immutable Route Group implementation that handles grouped routes.
public struct CompiledRouteGroup<
        let prefixEndpointsCount: Int,
        ImmutableStaticMiddlewareStorage: StaticMiddlewareStorageProtocol,
        ImmutableDynamicMiddlewareStorage: DynamicMiddlewareStorageProtocol,
        ImmutableStaticResponders: StaticResponderStorageProtocol,
        ImmutableDynamicResponders: DynamicResponderStorageProtocol,
        MutableStaticResponders: MutableStaticResponderStorageProtocol,
        MutableDynamicResponders: MutableDynamicResponderStorageProtocol
    >: RouteGroupProtocol {
    public let prefixEndpoints:InlineArray<prefixEndpointsCount, String>
    public let immutableStaticMiddleware:ImmutableStaticMiddlewareStorage?
    public let immutableDynamicMiddleware:ImmutableDynamicMiddlewareStorage?

    public let immutableStaticResponders:ImmutableStaticResponders
    public let immutableDynamicResponders:ImmutableDynamicResponders

    public let mutableStaticResponders:MutableStaticResponders
    public let mutableDynamicResponders:MutableDynamicResponders

    public init(
        prefixEndpoints: InlineArray<prefixEndpointsCount, String>,
        immutableStaticMiddleware: ImmutableStaticMiddlewareStorage?,
        immutableDynamicMiddleware: ImmutableDynamicMiddlewareStorage?,
        immutableStaticResponders: ImmutableStaticResponders,
        immutableDynamicResponders: ImmutableDynamicResponders,
        mutableStaticResponders: MutableStaticResponders,
        mutableDynamicResponders: MutableDynamicResponders
    ) {
        self.prefixEndpoints = prefixEndpoints
        self.immutableStaticMiddleware = immutableStaticMiddleware
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
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        if try immutableStaticResponders.respond(router: router, socket: socket, startLine: request.startLine) {
            return true
        } else if try mutableStaticResponders.respond(router: router, socket: socket, startLine: request.startLine) {
            return true
        } else if try await immutableDynamicResponders.respond(router: router, socket: socket, request: &request) {
            return true
        } else if try await mutableDynamicResponders.respond(router: router, socket: socket, request: &request) {
            return true
        } else {
            return false
        }
    }
}
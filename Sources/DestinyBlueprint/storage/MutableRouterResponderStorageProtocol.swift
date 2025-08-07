
/// Core mutable Router Responder Storage protocol that stores route responders for routes.
public protocol MutableRouterResponderStorageProtocol: AnyObject, RouterResponderStorageProtocol {

    /// Registers a static route responder to the given route path.
    func register(
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    )

    /// Registers a dynamic route responder to the given route path.
    func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    )

}
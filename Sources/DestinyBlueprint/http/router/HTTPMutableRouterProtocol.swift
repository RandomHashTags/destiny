
/// Core HTTPRouter protocol that can modify features after the server has started.
public protocol HTTPMutableRouterProtocol: AnyObject, HTTPRouterProtocol {

    /// Registers a static route responder to the given route path.
    func register(
        caseSensitive: Bool,
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    )

    /// Registers a dynamic route responder to the given route path.
    func register(
        caseSensitive: Bool,
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    )
}

public protocol MutableDynamicResponderStorageProtocol: AnyObject, CustomDebugStringConvertible, DynamicResponderStorageProtocol {
    /// Registers a dynamic route responder to the given route path.
    func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    )
}
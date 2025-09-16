
#if MutableRouter

/// Core mutable protocol that stores dynamic responders for dynamic routes.
public protocol MutableDynamicResponderStorageProtocol: AnyObject, ResponderStorageProtocol {
    /// Registers a dynamic route responder to the given route path.
    func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    )
}

#endif
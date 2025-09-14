
/// Core mutable protocol that stores static responders for static routes.
public protocol MutableStaticResponderStorageProtocol: AnyObject, StaticResponderStorageProtocol {
    /// Registers a static route responder to the given route path.
    func register(
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    )
}
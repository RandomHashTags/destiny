
public protocol MutableStaticResponderStorageProtocol: AnyObject, StaticResponderStorageProtocol {
    /// Registers a static route responder to the given route path.
    func register(
        path: SIMD64<UInt8>,
        _ responder: some StaticRouteResponderProtocol
    )
}
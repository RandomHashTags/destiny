
public protocol MutableStaticResponderStorageProtocol: AnyObject, CustomDebugStringConvertible, StaticResponderStorageProtocol {
    func register(
        path: SIMD64<UInt8>,
        _ responder: some StaticRouteResponderProtocol
    )
}
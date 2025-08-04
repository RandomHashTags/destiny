
public protocol MutableStaticResponderStorageProtocol: StaticResponderStorageProtocol, ~Copyable {
    mutating func register(
        path: SIMD64<UInt8>,
        _ responder: some StaticRouteResponderProtocol
    )
}
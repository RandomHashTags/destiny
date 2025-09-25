
#if RoutePath

public protocol RoutePathComponentProtocol: Equatable, Sendable {
}

// MARK: Default conformances
extension SIMD64<UInt8>: RoutePathComponentProtocol {}

#endif
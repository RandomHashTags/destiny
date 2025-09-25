
#if RoutePath

public enum RoutePathComponent: RoutePathComponentProtocol {
    case catchall
    case literal(SIMD64<UInt8>)
    case parameter
    case query([SIMD64<UInt8>])

    #if Inlinable
    @inlinable
    #endif
    public var isCatchall: Bool {
        self == .catchall
    }

    #if Inlinable
    @inlinable
    #endif
    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    #if Inlinable
    @inlinable
    #endif
    public var isParameter: Bool {
        self == .parameter
    }

    #if Inlinable
    @inlinable
    #endif
    public var isQuery: Bool {
        guard case .query = self else { return false }
        return true
    }
}

#endif

#if RoutePath

public enum RoutePathComponent: RoutePathComponentProtocol {
    case catchall
    case literal(SIMD64<UInt8>)
    case parameter
    case query([SIMD64<UInt8>])

    public var isCatchall: Bool {
        self == .catchall
    }

    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    public var isParameter: Bool {
        self == .parameter
    }

    public var isQuery: Bool {
        guard case .query = self else { return false }
        return true
    }
}

#endif

public enum RoutePathComponent: RoutePathComponentProtocol {
    case catchall
    case literal(SIMD64<UInt8>)
    case parameter
    case queryable(SIMD64<UInt8>)

    @inlinable
    public var isCatchall: Bool {
        self == .catchall
    }

    @inlinable
    public var isParameter: Bool {
        self == .parameter
    }

    @inlinable
    public var isQueryable: Bool {
        switch self {
        case .queryable: true
        default: false
        }
    }
}

// MARK: ExpressibleByStringLiteral
extension RoutePathComponent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        if value == "**" {
            self = .catchall
        } else if value.first == ":" || value.first == "*" {
            self = .parameter
        } else if let questionMarkIndex = value.firstIndex(of: "?") {
            var prefix = value[value.startIndex..<questionMarkIndex]
            var simd = SIMD64<UInt8>()
            prefix.withUTF8 {
                for i in 0..<$0.count {
                    simd[i] = $0[i]
                }
            }
            self = .queryable(simd)
        } else if value.hasSuffix("SIMD64<UInt8>(") {
            let bytes = value.split(separator: "(")[1].split(separator: ")")[0].split(separator: ", ").compactMap({ UInt8($0) })
            self = .literal(.init(bytes))
        } else {
            var simd = SIMD64<UInt8>()
            let span = value.utf8Span.span
            for i in span.indices {
                simd[i] = span[i]
            }
            self = .literal(simd)
        }
    }
}

// MARK: Parse
extension RoutePathComponent {
    public static func parse(_ string: String) -> [Self] {
        var i = 0
        let span = string.utf8Span.span
        var paths = [Self]()
        while i < span.count {
            let endIndex = min(i + 64, span.count)
            let slice = string[string.index(string.startIndex, offsetBy: i)..<string.index(string.startIndex, offsetBy: endIndex)]
            // TODO: check slice contents to make sure it does not contain wildcards, not just at the beginning
            paths.append(.init(stringLiteral: String(slice)))
            i += 64
        }
        return paths
    }
}
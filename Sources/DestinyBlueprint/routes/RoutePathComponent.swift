
public enum RoutePathComponent: RoutePathComponentProtocol {
    case catchall
    case literal(SIMD64<UInt8>)
    case parameter
    case query([SIMD64<UInt8>])

    @inlinable
    public var isCatchall: Bool {
        self == .catchall
    }

    @inlinable
    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    @inlinable
    public var isParameter: Bool {
        self == .parameter
    }

    @inlinable
    public var isQuery: Bool {
        guard case .query = self else { return false }
        return true
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
            var simds = [SIMD64<UInt8>]()
            prefix.withUTF8 { prefixPointer in
                var i = 0
                if prefixPointer.count > 64 {
                    let simdsCount = prefixPointer.count / 64
                    simds.reserveCapacity(simdsCount + 1)
                    for i in 0..<simdsCount {
                        var simd = SIMD64<UInt8>()
                        withUnsafeMutablePointer(to: &simd, {
                            copyMemory($0, prefixPointer.baseAddress! + (i * 64), 64)
                        })
                        simds.append(simd)
                    }
                    i = simdsCount * 64
                }
                var simd = SIMD64<UInt8>()
                while i < prefixPointer.count {
                    simd[i] = prefixPointer[i]
                    i += 1
                }
                simds.append(simd)
            }
            self = .query(simds)
        } else if value.hasPrefix("SIMD64<UInt8>(") {
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
    /// Splits a `String`, by the forward slash character (`/`), into respective route path components.
    public static func parse(_ string: String) -> [Self] {
        return parse(subSequence: string.split(separator: "/"))
    }

    public static func parse(subSequence: some Sequence<Substring>) -> [Self] {
        var paths = [Self]()
        loop: for splitSlice in subSequence {
            let splitSliceCount = splitSlice.count
            if splitSliceCount > 64 {
                var i = 0
                while i < splitSliceCount {
                    let startIndex = splitSlice.index(splitSlice.startIndex, offsetBy: i)
                    i += 64
                    let endIndex = min(i, splitSliceCount)
                    let slice = splitSlice[startIndex..<splitSlice.index(splitSlice.startIndex, offsetBy: endIndex)]
                    if !doTheThing(slice: slice, paths: &paths) {
                        break loop
                    }
                }
            } else {
                if !doTheThing(slice: splitSlice, paths: &paths) {
                    break loop
                }
            }
        }
        return paths
    }

    /// - Returns: Whether or not to continue parsing
    private static func doTheThing(
        slice: Substring,
        paths: inout [Self]
    ) -> Bool {
        if slice == "**" {
            paths.append(.catchall)
            return false
        } else if slice.first == ":" || slice.first == "*" {
            paths.append(.parameter)
        } else if let index = slice.firstIndex(of: "?") {
            if slice.startIndex < index {
                let pre = slice[slice.startIndex..<index]
                paths.append(.init(stringLiteral: String(pre)))

                let post = slice[slice.index(after: index)...]
                let postParsed = parse(String(post))
                paths.append(.query(postParsed.compactMap({
                    guard case let .literal(queryValue) = $0 else { return nil }
                    return queryValue
                })))
            }
        } else {
            paths.append(.init(stringLiteral: String(slice)))
        }
        return true
    }
}

// MARK: Parse compiled
extension RoutePathComponent {
    /// Converts an array of unoptimized parsed route path components to an optimized
    /// array of route path components suitable for optimal runtime performance.
    public static func parseCompiled(_ components: [Self]) -> [Self] {
        guard !components.isEmpty else { return [] }
        var components = components
        var paths = [Self]()
        var simd = SIMD64<UInt8>.zero
        var simdIndex = 0
        loop: while !components.isEmpty {
            let component = components.removeFirst()
            if simdIndex != 0 {
                simd[simdIndex] = .forwardSlash
                simdIndex += 1
                if simdIndex == 64 {
                    paths.append(.literal(simd))
                    simd = .zero
                    simdIndex = 0
                }
            }
            switch component {
            case .catchall, .parameter, .query:
                if simdIndex != 0 {
                    simd[simdIndex] = .forwardSlash
                    paths.append(.literal(simd))
                    simd = .zero
                    simdIndex = 0
                }
                paths.append(component)
            case .literal(let literal):
                var literalIndex = 0
                if simdIndex == 0 {
                    simd = literal
                    for i in 0..<64 {
                        if literal[i] == 0 {
                            simdIndex = i
                            break
                        }
                    }
                } else {
                    var i = 0
                    while simdIndex < 64 && literal[i] != 0 {
                        simd[simdIndex] = literal[i]
                        simdIndex += 1
                        i += 1
                    }
                    if literal[i] != 0 {
                        literalIndex = i
                    }
                }
                if simdIndex < 64 {
                    for i in simdIndex..<64 {
                        if simd[i] == 0 {
                            simdIndex = i
                            if !components.isEmpty {
                                continue loop
                            }
                        }
                    }
                }
                paths.append(.literal(simd))
                simd = .zero
                simdIndex = 0
                var literalValue = literal[literalIndex]
                while simdIndex < 64 && literalIndex < 64 && literalValue != 0 {
                    simd[simdIndex] = literalValue
                    simdIndex += 1
                    literalIndex += 1
                    literalValue = literal[literalIndex]
                }
            }
        }
        return paths
    }
}
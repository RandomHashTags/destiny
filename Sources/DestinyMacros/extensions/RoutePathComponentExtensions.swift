
#if RoutePath

import DestinyBlueprint

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

#endif

@_marker
public protocol PerfectHashGeneratorProtocol: Sendable, ~Copyable {
}

extension PerfectHashGeneratorProtocol {
    public static func extractKeyClosure<T: PerfectHashable>(
        positions: [64 of Int],
        maxBytes: Int
    ) -> (T) -> UInt64 {
        switch maxBytes {
        case 1:
            let positions = [1 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey1(positions: positions) }
        case 2:
            let positions2 = [2 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey2(positions: positions2) }
        case 3:
            let positions3 = [3 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey3(positions: positions3) }
        case 4:
            let positions = [4 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey4(positions: positions) }
        case 5:
            let positions = [5 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey5(positions: positions) }
        case 6:
            let positions = [6 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey6(positions: positions) }
        case 7:
            let positions = [7 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey7(positions: positions) }
        default:
            let positions8 = [8 of Int]({ positions[unchecked: $0] })
            return { $0.extractKey8(positions: positions8) }
        }
    }
}
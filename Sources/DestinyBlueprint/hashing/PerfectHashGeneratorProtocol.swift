
public protocol PerfectHashGeneratorProtocol: Sendable, ~Copyable {
}

extension PerfectHashGeneratorProtocol {
    @inlinable
    public static func extractKeyClosure<T: PerfectHashable>(
        positions: InlineArray<64, Int>,
        maxBytes: Int
    ) -> (T) -> UInt64 {
        switch maxBytes {
        case 1:
            let positions = InlineArray<1, Int>({ positions[$0] })
            return { $0.extractKey1(positions: positions) }
        case 2:
            let positions2 = InlineArray<2, Int>({ positions[$0] })
            return { $0.extractKey2(positions: positions2) }
        case 3:
            let positions3 = InlineArray<3, Int>({ positions[$0] })
            return { $0.extractKey3(positions: positions3) }
        case 4:
            let positions = InlineArray<4, Int>({ positions[$0] })
            return { $0.extractKey4(positions: positions) }
        case 5:
            let positions = InlineArray<5, Int>({ positions[$0] })
            return { $0.extractKey5(positions: positions) }
        case 6:
            let positions = InlineArray<6, Int>({ positions[$0] })
            return { $0.extractKey6(positions: positions) }
        case 7:
            let positions = InlineArray<7, Int>({ positions[$0] })
            return { $0.extractKey7(positions: positions) }
        default:
            let positions8 = InlineArray<8, Int>({ positions[$0] })
            return { $0.extractKey8(positions: positions8) }
        }
    }
}
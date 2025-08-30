
public protocol PerfectHashGeneratorProtocol: Sendable, ~Copyable {
}

extension PerfectHashGeneratorProtocol {
    @inlinable
    public static func extractKeyClosure<T: PerfectHashable>(
        positions: InlineArray<64, Int>,
        maxBytes: Int
    ) -> (T) -> UInt64 {
        switch maxBytes {
        case 2:
            let positions2:InlineArray<2, Int> = [positions[0], positions[1]]
            return { $0.extractKey2(positions: positions2) }
        case 4:
            let positions4:InlineArray<4, Int> = [positions[0], positions[1], positions[2], positions[3]]
            return { $0.extractKey4(positions: positions4) }
        case 8:
            let positions8:InlineArray<8, Int> = [positions[0], positions[1], positions[2], positions[3], positions[4], positions[5], positions[6], positions[7]]
            return { $0.extractKey8(positions: positions8) }
        case 16:
            let positions16:InlineArray<16, Int> = [
                positions[0], positions[1], positions[2], positions[3], positions[4], positions[5], positions[6], positions[7],
                positions[8], positions[9], positions[10], positions[11], positions[12], positions[13], positions[14], positions[15]
            ]
            return { $0.extractKey16(positions: positions16) }
        case 32:
            let positions32:InlineArray<32, Int> = [
                positions[0], positions[1], positions[2], positions[3], positions[4], positions[5], positions[6], positions[7],
                positions[8], positions[9], positions[10], positions[11], positions[12], positions[13], positions[14], positions[15],
                positions[16], positions[17], positions[18], positions[19], positions[20], positions[21], positions[22], positions[23],
                positions[24], positions[25], positions[26], positions[27], positions[28], positions[29], positions[30], positions[31]
            ]
            return { $0.extractKey32(positions: positions32) }
        case 64:
            return { $0.extractKey64(positions: positions) }
        default:
            let positions8:InlineArray<8, Int> = [positions[0], positions[1], positions[2], positions[3], positions[4], positions[5], positions[6], positions[7]]
            return { $0.extractKey8(positions: positions8) }
        }
    }
}
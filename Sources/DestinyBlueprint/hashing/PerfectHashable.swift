
public protocol PerfectHashable: Sendable, SIMD where Scalar == UInt8 {
    func extractKey4(positions: InlineArray<4, Int>) -> UInt64
    func extractKey8(positions: InlineArray<8, Int>) -> UInt64
    func extractKey16(positions: InlineArray<16, Int>) -> UInt64
    func extractKey32(positions: InlineArray<32, Int>) -> UInt64
}

// MARK: SIMD64 extension
extension SIMD64<UInt8>: PerfectHashable {
    @inlinable
    public func extractKey4(positions: InlineArray<4, Int>) -> UInt64 {
        return withUnsafeBytes(of: (self[positions[0]], self[positions[1]], self[positions[2]], self[positions[3]])) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey8(positions: InlineArray<8, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey16(positions: InlineArray<16, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]],
            self[positions[8]],
            self[positions[9]],
            self[positions[10]],
            self[positions[11]],
            self[positions[12]],
            self[positions[13]],
            self[positions[14]],
            self[positions[15]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey32(positions: InlineArray<32, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]],
            self[positions[8]],
            self[positions[9]],
            self[positions[10]],
            self[positions[11]],
            self[positions[12]],
            self[positions[13]],
            self[positions[14]],
            self[positions[15]],
            self[positions[16]],
            self[positions[17]],
            self[positions[18]],
            self[positions[19]],
            self[positions[20]],
            self[positions[21]],
            self[positions[22]],
            self[positions[23]],
            self[positions[24]],
            self[positions[25]],
            self[positions[26]],
            self[positions[27]],
            self[positions[28]],
            self[positions[29]],
            self[positions[30]],
            self[positions[31]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
}
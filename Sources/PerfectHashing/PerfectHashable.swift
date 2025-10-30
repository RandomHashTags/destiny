
public protocol PerfectHashable: Sendable, SIMD where Scalar == UInt8 {
    func extractKey1(positions: InlineArray<1, Int>) -> UInt64
    func extractKey2(positions: InlineArray<2, Int>) -> UInt64
    func extractKey3(positions: InlineArray<3, Int>) -> UInt64
    func extractKey4(positions: InlineArray<4, Int>) -> UInt64
    func extractKey5(positions: InlineArray<5, Int>) -> UInt64
    func extractKey6(positions: InlineArray<6, Int>) -> UInt64
    func extractKey7(positions: InlineArray<7, Int>) -> UInt64
    func extractKey8(positions: InlineArray<8, Int>) -> UInt64
}

// MARK: SIMD64 extension
extension SIMD64<UInt8>: PerfectHashable {
    public func extractKey1(positions: InlineArray<1, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            self[positions[unchecked: 0]]
        )) {
            $0.load(as: UInt64.self)
        }
    }

    public func extractKey2(positions: InlineArray<2, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            0,
            0,
            0,
            0,
            0,
            0,
            self[positions[unchecked: 0]],
            self[positions[unchecked: 1]]
        )) {
            $0.load(as: UInt64.self)
        }
    }

    public func extractKey3(positions: InlineArray<3, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            0,
            0,
            0,
            0,
            0,
            self[positions[unchecked: 0]],
            self[positions[unchecked: 1]],
            self[positions[unchecked: 2]]
        )) {
            $0.load(as: UInt64.self)
        }
    }

    public func extractKey4(positions: InlineArray<4, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            0,
            0,
            0,
            0,
            self[positions[unchecked: 0]],
            self[positions[unchecked: 1]],
            self[positions[unchecked: 2]],
            self[positions[unchecked: 3]]
        )) {
            $0.load(as: UInt64.self)
        }
    }

    public func extractKey5(positions: InlineArray<5, Int>) -> UInt64 {
        return withUnsafeBytes(of: self, { b in
            return withUnsafeBytes(of: (
                0,
                0,
                0,
                b[positions[unchecked: 0]],
                b[positions[unchecked: 1]],
                b[positions[unchecked: 2]],
                b[positions[unchecked: 3]],
                b[positions[unchecked: 4]]
            )) {
                $0.load(as: UInt64.self)
            }
        })
    }

    public func extractKey6(positions: InlineArray<6, Int>) -> UInt64 {
        return withUnsafeBytes(of: self, { b in
            return withUnsafeBytes(of: (
                0,
                0,
                b[positions[unchecked: 0]],
                b[positions[unchecked: 1]],
                b[positions[unchecked: 2]],
                b[positions[unchecked: 3]],
                b[positions[unchecked: 4]],
                b[positions[unchecked: 5]]
            )) {
                $0.load(as: UInt64.self)
            }
        })
    }

    public func extractKey7(positions: InlineArray<7, Int>) -> UInt64 {
        return withUnsafeBytes(of: self, { b in
            return withUnsafeBytes(of: (
                0,
                b[positions[unchecked: 0]],
                b[positions[unchecked: 1]],
                b[positions[unchecked: 2]],
                b[positions[unchecked: 3]],
                b[positions[unchecked: 4]],
                b[positions[unchecked: 5]],
                b[positions[unchecked: 6]]
            )) {
                $0.load(as: UInt64.self)
            }
        })
    }

    public func extractKey8(positions: InlineArray<8, Int>) -> UInt64 {
        return withUnsafeBytes(of: self, { b in
            return withUnsafeBytes(of: (
                b[positions[unchecked: 0]],
                b[positions[unchecked: 1]],
                b[positions[unchecked: 2]],
                b[positions[unchecked: 3]],
                b[positions[unchecked: 4]],
                b[positions[unchecked: 5]],
                b[positions[unchecked: 6]],
                b[positions[unchecked: 7]]
            )) {
                $0.load(as: UInt64.self)
            }
        })
    }
}

extension SIMD64<UInt8> {
    /// - Complexity: O(*n*) if `string` is non-contiguous, O(1) if already contiguous.
    #if Inlinable
    @inlinable
    #endif
    public init(_ string: inout String) {
        var item = Self()
        string.withUTF8 { p in
            for i in 0..<Swift.min(p.count, Self.scalarCount) {
                item[i] = Scalar(p[i])
            }
        }
        self = item
    }

    /// - Complexity: O(*n*) if `string` is non-contiguous, O(1) if already contiguous.
    #if Inlinable
    @inlinable
    #endif
    public init(_ string: String) {
        var s = string
        self = .init(&s)
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public var leadingNonzeroByteCountSIMD: Int {
        for i in 0..<scalarCount {
            if self[i] == 0 {
                return i
            }
        }
        return scalarCount
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func stringSIMD() -> String {
        let amount = leadingNonzeroByteCountSIMD
        var characters = [Character](repeating: Character(Unicode.Scalar(0)), count: amount)
        for i in 0..<amount {
            characters[i] = Character(UnicodeScalar(self[i]))
        }
        return String(characters)
    }
}
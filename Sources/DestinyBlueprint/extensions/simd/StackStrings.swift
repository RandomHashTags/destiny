
extension SIMD where Scalar: BinaryInteger {
    /// - Complexity: O(*n*) if `string` is non-contiguous, O(1) if already contiguous.
    @inlinable
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
    @inlinable
    public init(_ string: String) {
        var s = string
        self = .init(&s)
    }

    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCountSIMD: Int {
        for i in 0..<scalarCount {
            if self[i] == 0 {
                return i
            }
        }
        return scalarCount
    }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func hasPrefixSIMD<T: SIMD>(_ simd: T) -> Bool where T.Scalar: BinaryInteger, Scalar == T.Scalar {
        var nibble = T()
        for i in 0..<T.scalarCount {
            nibble[i] = self[i]
        }
        return nibble == simd
    }

    /// - Complexity: O(1)
    @inlinable
    public func splitSIMD(separator: Scalar) -> [Self] { // TODO: make SIMD fast
        var anchor = 0
        var array:[Self] = []
        array.reserveCapacity(2)
        for i in 0..<scalarCount {
            if self[i] == separator {                
                if anchor < i {
                    var slice = Self(), sliceIndex:Int = 0
                    for j in anchor..<i {
                        slice[sliceIndex] = self[j]
                        sliceIndex += 1
                    }
                    if sliceIndex != 0 {
                        array.append(slice)
                    }
                }
                anchor = i+1
            }
        }
        if array.isEmpty {
            return [self]
        }
        var endingSlice = Self(), sliceIndex:Int = 0
        for i in anchor..<scalarCount {
            endingSlice[sliceIndex] = self[i]
            sliceIndex += 1
        }
        array.append(endingSlice)
        return array
    }
}
extension SIMD where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    public func stringSIMD() -> String {
        let amount = leadingNonzeroByteCountSIMD
        var characters = [Character](repeating: Character(Unicode.Scalar(0)), count: amount)
        for i in 0..<amount {
            characters[i] = Character(Unicode.Scalar(self[i]))
        }
        return String(characters)
    }
}

// MARK: scalars() O(1)
// implementation should never change
extension SIMD2 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
extension SIMD4 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
extension SIMD8 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
extension SIMD16 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
extension SIMD32 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
extension SIMD64 where Scalar == UInt8 {
    @inlinable public func scalars() -> [Scalar] { withUnsafeBytes(of: self, { Array($0) }) }
}
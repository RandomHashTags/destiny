
// MARK: SIMD2
extension SIMD2 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        if x == byte { return 0 }
        if y == byte { return 1 }
        return scalarCount
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD2<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD2<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonByteCount(byte: byte) }
        if (highHalf .!= byte_simd) != all_nonbyte { return 2 + highHalf.leadingNonByteCount(byte: byte) }
        return scalarCount
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD4<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonByteCount(byte: byte) }
        if (highHalf .!= byte_simd) != all_nonbyte { return 4 + highHalf.leadingNonByteCount(byte: byte) }
        return scalarCount
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD8<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonByteCount(byte: byte) }
        if (highHalf .!= byte_simd) != all_nonbyte { return 8 + highHalf.leadingNonByteCount(byte: byte) }
        return scalarCount
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD16<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonByteCount(byte: byte) }
        if (highHalf .!= byte_simd) != all_nonbyte { return 16 + highHalf.leadingNonByteCount(byte: byte) }
        return scalarCount
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD32<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonByteCount(byte: byte) }
        if (highHalf .!= byte_simd) != all_nonbyte { return 32 + highHalf.leadingNonByteCount(byte: byte) }
        return scalarCount
    }
}
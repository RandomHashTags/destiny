
// MARK: SIMD2
extension SIMD2 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        if x == 0 { return 0 }
        if y == 0 { return 1 }
        return scalarCount
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        let all_nonzero:SIMDMask<SIMD2<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 2 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        let all_nonzero:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 4 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        let all_nonzero:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 8 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        let all_nonzero:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 16 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var leadingNonzeroByteCount: Int {
        let all_nonzero:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 32 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
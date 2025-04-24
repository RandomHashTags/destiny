//
//  SIMDExtensions+TrailingZeroByteCount.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD2
extension SIMD2 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        if y != 0 { return 0 }
        if x != 0 { return 1 }
        return scalarCount
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        let all_zero:SIMDMask<SIMD2<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (highHalf .== .zero) != all_zero { return highHalf.trailingZeroByteCount }
        if (lowHalf  .== .zero) != all_zero { return 2 + lowHalf.trailingZeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        let all_zero:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (highHalf .== .zero) != all_zero { return highHalf.trailingZeroByteCount }
        if (lowHalf  .== .zero) != all_zero { return 4 + lowHalf.trailingZeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        let all_zero:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (highHalf .== .zero) != all_zero { return highHalf.trailingZeroByteCount }
        if (lowHalf  .== .zero) != all_zero { return 8 + lowHalf.trailingZeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        let all_zero:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (highHalf .== .zero) != all_zero { return highHalf.trailingZeroByteCount }
        if (lowHalf  .== .zero) != all_zero { return 16 + lowHalf.trailingZeroByteCount }
        return scalarCount
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar: BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public var trailingZeroByteCount: Int {
        let all_zero:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (highHalf .== .zero) != all_zero { return highHalf.trailingZeroByteCount }
        if (lowHalf  .== .zero) != all_zero { return 32 + lowHalf.trailingZeroByteCount }
        return scalarCount
    }
}
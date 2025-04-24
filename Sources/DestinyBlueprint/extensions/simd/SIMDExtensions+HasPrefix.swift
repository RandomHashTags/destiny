//
//  SIMDExtensions+HasPrefix.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD4
extension SIMD4 where Scalar: BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf }
}

// MARK: SIMD8
extension SIMD8 where Scalar: BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf }
}

// MARK: SIMD16
extension SIMD16 where Scalar: BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf }
}

// MARK: SIMD32
extension SIMD32 where Scalar: BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD16<Scalar>) -> Bool { simd == lowHalf }
}

// MARK: SIMD64
extension SIMD64 where Scalar: BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD16<Scalar>) -> Bool { simd == lowHalf.lowHalf }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// 
    /// - Complexity: O(1)
    @inlinable public func hasPrefix(_ simd: SIMD32<Scalar>) -> Bool { simd == lowHalf }
}
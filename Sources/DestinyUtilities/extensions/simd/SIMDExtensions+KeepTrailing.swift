//
//  SIMDExtensions+KeepTrailing.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD2
public extension SIMD2 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1:
            x = 0
        default:
            break
        }
    }
}

// MARK: SIMD4
public extension SIMD4 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1:
            x = 0
            y = 0
            z = 0
        case 2:
            lowHalf = .init()
        case 3:
            x = 0
        default:
            break
        }
    }
}

// MARK: SIMD8
public extension SIMD8 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...4:
            lowHalf = .init()
            highHalf.keepTrailing(length)
        case 5...7:
            lowHalf.keepTrailing(length - 4)
        default:
            break
        }
    }
}

// MARK: SIMD16
public extension SIMD16 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...8:
            lowHalf = .init()
            highHalf.keepTrailing(length)
        case 9...15:
            lowHalf.keepTrailing(length - 8)
        default:
            break
        }
    }
}

// MARK: SIMD32
public extension SIMD32 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...16:
            lowHalf = .init()
            highHalf.keepTrailing(length)
        case 17...31:
            lowHalf.keepTrailing(length - 16)
        default:
            break
        }
    }
}

// MARK: SIMD64
public extension SIMD64 where Scalar : BinaryInteger {
    /// Keeps the trailing scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...32:
            lowHalf = .init()
            highHalf.keepTrailing(length)
        case 33...63:
            lowHalf.keepTrailing(length - 32)
        default:
            break
        }
    }
}
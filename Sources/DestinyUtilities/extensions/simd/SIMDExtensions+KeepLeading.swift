//
//  SIMDExtensions+KeepLeading.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD2
public extension SIMD2 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1:
            y = 0
        default:
            break
        }
    }
}

// MARK: SIMD4
public extension SIMD4 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1:
            y = 0
            z = 0
            w = 0
        case 2:
            highHalf = .init()
        case 3:
            w = 0
        default:
            break
        }
    }
}

// MARK: SIMD8
public extension SIMD8 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...4:
            lowHalf.keepLeading(length)
            highHalf = .init()
        case 5...7:
            highHalf.keepLeading(length - 4)
        default:
            break
        }
    }
}

// MARK: SIMD16
public extension SIMD16 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...8:
            lowHalf.keepLeading(length)
            highHalf = .init()
        case 9...15:
            highHalf.keepLeading(length - 8)
        default:
            break
        }
    }
}

// MARK: SIMD32
public extension SIMD32 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...16:
            lowHalf.keepLeading(length)
            highHalf = .init()
        case 17...31:
            highHalf.keepLeading(length - 16)
        default:
            break
        }
    }
}

// MARK: SIMD64
public extension SIMD64 where Scalar : BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    mutating func keepLeading(_ length: Int) {
        switch length {
        case _ where length <= 0:
            self = .init()
        case 1...32:
            lowHalf.keepLeading(length)
            highHalf = .init()
        case 33...63:
            highHalf.keepLeading(length - 32)
        default:
            break
        }
    }
}
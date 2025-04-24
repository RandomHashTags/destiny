//
//  SIMDExtensions+DropTrailing.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD2
extension SIMD2 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    @inlinable
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1:
            self[1] = 0
        default:
            self = .init()
        }
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    @inlinable
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1:
            highHalf[1] = 0
        case 2:
            highHalf = .init()
        case 3:
            highHalf = .init()
            lowHalf[1] = 0
        default:
            self = .init()
        }
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    @inlinable
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1...4:
            highHalf.dropTrailing(length)
        case 5...7:
            highHalf = .init()
            lowHalf.dropTrailing(length - 4)
        default:
            self = .init()
        }
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1...8:
            highHalf.dropTrailing(length)
        case 9...15:
            highHalf = .init()
            lowHalf.dropTrailing(length - 8)
        default:
            self = .init()
        }
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1...16:
            highHalf.dropTrailing(length)
        case 17...31:
            highHalf = .init()
            lowHalf.dropTrailing(length - 16)
        default:
            self = .init()
        }
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar: BinaryInteger {
    /// Sets the trailing scalars to zero. 
    /// 
    /// - Parameters:
    ///   - length: The number of trailing scalars to set to zero.
    /// - Complexity: O(1)
    public mutating func dropTrailing(_ length: Int) {
        switch length {
        case _ where length <= 0:
            break
        case 1...32:
            highHalf.dropTrailing(length)
        case 33...63:
            highHalf = .init()
            lowHalf.dropTrailing(length - 32)
        default:
            self = .init()
        }
    }
}
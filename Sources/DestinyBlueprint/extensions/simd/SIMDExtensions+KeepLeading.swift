
// MARK: SIMD2
extension SIMD2 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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
extension SIMD4 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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
extension SIMD8 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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
extension SIMD16 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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
extension SIMD32 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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
extension SIMD64 where Scalar: BinaryInteger {
    /// Keeps the leading scalar values and sets everything else to zero.
    /// 
    /// - Parameters:
    ///   - length: The number of leading scalars to keep.
    /// - Complexity: O(1)
    @inlinable
    public mutating func keepLeading(_ length: Int) {
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

// MARK: SIMD2
extension SIMD2 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        return y == 0 ? [] : x == 0 ? [y] : [x, y]
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        if (self .!= .zero) == .init(repeating: true) {
            return [x, y, z, w]
        }
        if (highHalf .!= .zero) != .init(repeating: true) {
            return highHalf.trailingScalars()
        }
        return lowHalf.trailingScalars() + [z, w]
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        if (highHalf .!= .zero) != .init(repeating: true) {
            return highHalf.trailingScalars()
        }
        return lowHalf.trailingScalars() + [highHalf.x, highHalf.y, highHalf.z, highHalf.w]
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        if (highHalf .!= .zero) != .init(repeating: true) {
            return highHalf.trailingScalars()
        }
        return lowHalf.trailingScalars() + highHalf.scalars()
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        if (highHalf .!= .zero) != .init(repeating: true) {
            return highHalf.trailingScalars()
        }
        return lowHalf.trailingScalars() + highHalf.scalars()
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func trailingScalars() -> [Scalar] {
        if (highHalf .!= .zero) != .init(repeating: true) {
            return highHalf.trailingScalars()
        }
        return lowHalf.trailingScalars() + highHalf.scalars()
    }

    /// Creates a `String` based on this vector's trailing scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func trailingString() -> String {
        return String(decoding: trailingScalars(), as: UTF8.self)
    }
}
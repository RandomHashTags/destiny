
// MARK: SIMD2
extension SIMD2 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        return x == 0 ? [] : y == 0 ? [x] : [x, y]
    }
    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        if (self .!= .zero) == .init(repeating: true) {
            return [x, y, z, w]
        }
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.leadingScalars()
        }
        return [x, y] + highHalf.leadingScalars()
    }

    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD8
extension SIMD8 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.leadingScalars()
        }
        return lowHalf.leadingScalars() + highHalf.leadingScalars()
    }

    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD16
extension SIMD16 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.leadingScalars()
        }
        return lowHalf.leadingScalars() + highHalf.leadingScalars()
    }

    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD32
extension SIMD32 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.leadingScalars()
        }
        return lowHalf.leadingScalars() + highHalf.leadingScalars()
    }

    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}

// MARK: SIMD64
extension SIMD64 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func leadingScalars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.leadingScalars()
        }
        return lowHalf.leadingScalars() + highHalf.leadingScalars()
    }

    /// Creates a `String` based on this vector's leading scalars.
    /// 
    /// - Complexity: O(1)
    @inlinable
    public func leadingString() -> String {
        return String(decoding: leadingScalars(), as: UTF8.self)
    }
}
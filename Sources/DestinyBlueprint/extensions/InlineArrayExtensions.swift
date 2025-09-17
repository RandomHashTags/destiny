
import VariableLengthArray

// MARK: VLArray
extension VLArray where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        return try body(UnsafeBufferPointer.init(storage))
    }

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString() -> String {
        return String.init(unsafeUninitializedCapacity: storage.count, initializingUTF8With: {
            return $0.initialize(from: storage).index
        })
    }

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString(offset: Int) -> String {
        let count = storage.count - offset
        let slice = storage[offset...]
        return String.init(unsafeUninitializedCapacity: count - offset, initializingUTF8With: {
            return $0.initialize(from: slice).index
        })
    }
}





// MARK: InlineArray





// MARK: HTTPSocketWritable
extension InlineArray: HTTPSocketWritable {
    /// Calls a closure with a pointer to the viewed contiguous storage.
    ///
    /// The buffer pointer passed as an argument to `body` is valid only
    /// during the execution of `withUnsafeBufferPointer(_:)`.
    /// Do not store or return the pointer for later use.
    ///
    /// Note: For an empty `Span`, the closure always receives a `nil` pointer.
    ///
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter
    ///   that points to the viewed contiguous storage. If `body` has
    ///   a return value, that value is also used as the return value
    ///   for the `withUnsafeBufferPointer(_:)` method. The closure's
    ///   parameter is valid only for the duration of its execution.
    /// - Returns: The return value of the `body` closure parameter.
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    @discardableResult
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        return try span.withUnsafeBufferPointer(body)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    @discardableResult
    public mutating func withUnsafeMutableBufferPointer<E: Error, R>(_ body: (UnsafeMutableBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        var ms = mutableSpan
        return try ms.withUnsafeMutableBufferPointer(body)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(to socket: some FileDescriptor) throws(SocketError) {
        var err:SocketError? = nil
        withUnsafePointer(to: self, {
            do throws(SocketError) {
                try socket.socketWriteBuffer($0, length: count)
            } catch {
                err = error
            }
        })
        if let err {
            throw err
        }
    }
}

// MARK: BufferWritable
extension InlineArray where Element == UInt8 { 
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        for i in indices {
            buffer[index] = self[i]
            index += 1
        }
    }
}

// MARK: string
extension InlineArray where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    public func string(offset: Index = 0) -> String {
        var s = ""
        var i = offset
        while i < endIndex {
            let char = self[i]
            if char == 0 {
                break
            }
            s.append(Character(Unicode.Scalar(char)))
            i += 1
        }
        return s
    }

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString() -> String {
        return self.withUnsafeBufferPointer { pointer in
            return String.init(unsafeUninitializedCapacity: pointer.count, initializingUTF8With: {
                return $0.initialize(from: pointer).index
            })
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString(offset: Int) -> String {
        return self.withUnsafeBufferPointer {
            let count = $0.count - offset
            let slice = $0[offset...]
            return String.init(unsafeUninitializedCapacity: count - offset, initializingUTF8With: {
                return $0.initialize(from: slice).index
            })
        }
    }
}

// MARK: Equatable
extension InlineArray where Element: Equatable {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in lhs.indices {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

extension InlineArray where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: some StringProtocol) -> Bool {
        let stringCount = rhs.count
        if lhs.count == rhs.count {
            for i in 0..<lhs.count {
                if lhs[i] != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
            }
            return true
        } else if lhs.count > stringCount {
            var i = 0
            while i < stringCount {
                if lhs[i] != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
                i += 1
            }
            return lhs[i] == 0
        } else {
            return false
        }
    }
}

// MARK: Pattern matching
extension InlineArray where Element: Equatable {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
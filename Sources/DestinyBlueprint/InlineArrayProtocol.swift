
/// Types conforming to this protocol indicate they're stored as an inline array.
public protocol InlineArrayProtocol: InlineCollectionProtocol, ~Copyable where Index == Int {
    init(repeating value: Element)

    func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R
}

// MARK Conformances
extension InlineArray: InlineArrayProtocol, HTTPSocketWritable {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func itemAt(index: Index) -> Element {
        self[index]
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public mutating func setItemAt(index: Int, element: Element) {
        self[index] = element
    }

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

// MARK: Extensions
extension Array where Element: BinaryInteger {
    public init<T: InlineArrayProtocol>(_ inlineArray: T) where T.Index == Index, Element == T.Element {
        self = .init()
        reserveCapacity(inlineArray.count)
        for i in inlineArray.indices {
            append(inlineArray.itemAt(index: i))
        }
    }
}

/// Types conforming to this protocol indicate they're stored as an inline array where their `Element` == `UInt8`.
public protocol InlineByteArrayProtocol: InlineArrayProtocol, BufferWritable, HTTPSocketWritable, ~Copyable where Element == UInt8 {
}

/// An inline array where the `Element` == `UInt8`.
public struct InlineByteArray<let count: Int>: InlineByteArrayProtocol {

    public typealias ArrayLiteralElement = UInt8

    @usableFromInline
    var _storage:InlineArray<count, UInt8>

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public init(repeating value: UInt8) {
        _storage = .init(repeating: value)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public init(_ storage: InlineArray<count, UInt8>) {
        _storage = storage
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var startIndex: Int {
        _storage.startIndex
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var endIndex: Int {
        _storage.endIndex
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var count: Int {
        count
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var isEmpty: Bool {
        _storage.isEmpty
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var indices: Range<Int> {
        _storage.indices
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        return try _storage.span.withUnsafeBufferPointer(body)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func index(after i: Int) -> Int {
        _storage.index(after: i)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func index(before i: Int) -> Int {
        _storage.index(before: i)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func itemAt(index: Int) -> UInt8 {
        _storage.itemAt(index: index)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public mutating func setItemAt(index: Int, element: UInt8) {
        _storage.setItemAt(index: index, element: element)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public mutating func swapAt(_ i: Int, _ j: Int) {
        _storage.swapAt(i, j)
    }

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
            buffer[index] = itemAt(index: i)
            index += 1
        }
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(to socket: some FileDescriptor) throws(SocketError) {
        try _storage.write(to: socket)
    }
}
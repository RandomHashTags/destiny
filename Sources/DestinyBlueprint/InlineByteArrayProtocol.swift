
/// Types conforming to this protocol indicate they're stored as an inline array where their `Element` == `UInt8`.
public protocol InlineByteArrayProtocol: InlineArrayProtocol, BufferWritable, HTTPSocketWritable, ~Copyable where Element == UInt8 {
}

/// An inline array where the `Element` == `UInt8`.
public struct InlineByteArray<let count: Int>: InlineByteArrayProtocol {

    public typealias ArrayLiteralElement = UInt8

    @usableFromInline
    var _storage:InlineArray<count, UInt8>

    @inlinable @inline(__always)
    public init(repeating value: UInt8) {
        _storage = .init(repeating: value)
    }

    @inlinable @inline(__always)
    public init(_ storage: InlineArray<count, UInt8>) {
        _storage = storage
    }

    @inlinable @inline(__always)
    public var startIndex: Int {
        _storage.startIndex
    }

    @inlinable @inline(__always)
    public var endIndex: Int {
        _storage.endIndex
    }

    @inlinable @inline(__always)
    public var count: Int {
        count
    }

    @inlinable @inline(__always)
    public var isEmpty: Bool {
        _storage.isEmpty
    }

    @inlinable @inline(__always)
    public var indices: Range<Int> {
        _storage.indices
    }

    @inlinable @inline(__always)
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        return try _storage.span.withUnsafeBufferPointer(body)
    }

    @inlinable @inline(__always)
    public func index(after i: Int) -> Int {
        _storage.index(after: i)
    }

    @inlinable @inline(__always)
    public func index(before i: Int) -> Int {
        _storage.index(before: i)
    }

    @inlinable @inline(__always)
    public func itemAt(index: Int) -> UInt8 {
        _storage.itemAt(index: index)
    }

    @inlinable @inline(__always)
    public mutating func setItemAt(index: Int, element: UInt8) {
        _storage.setItemAt(index: index, element: element)
    }

    @inlinable @inline(__always)
    public mutating func swapAt(_ i: Int, _ j: Int) {
        _storage.swapAt(i, j)
    }

    @inlinable @inline(__always)
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        for i in indices {
            buffer[index] = itemAt(index: i)
            index += 1
        }
    }

    @inlinable @inline(__always)
    public func write(to socket: some FileDescriptor) throws(SocketError) {
        try _storage.write(to: socket)
    }
}
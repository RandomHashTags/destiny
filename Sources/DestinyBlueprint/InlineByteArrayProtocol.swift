
/// Types conforming to this protocol indicate they're stored as an inline array where their `Element` == `UInt8`.
public protocol InlineByteArrayProtocol: InlineArrayProtocol, BufferWritable, HTTPSocketWritable, ~Copyable where Element == UInt8 {
}

public struct InlineByteArray<let count: Int>: InlineByteArrayProtocol {

    public typealias ArrayLiteralElement = UInt8

    @usableFromInline
    var _storage:InlineArray<count, UInt8>

    @inlinable
    public init(repeating value: UInt8) {
        _storage = .init(repeating: value)
    }

    @inlinable
    public init(_ storage: InlineArray<count, UInt8>) {
        _storage = storage
    }

    @inlinable public var startIndex: Int { _storage.startIndex }
    @inlinable public var endIndex: Int { _storage.endIndex }
    @inlinable public var count: Int { count }
    @inlinable public var isEmpty: Bool { _storage.isEmpty }

    @inlinable 
    public var indices: Range<Int> { _storage.indices }

    @inlinable
    public func index(after i: Int) -> Int {
        _storage.index(after: i)
    }

    @inlinable
    public func index(before i: Int) -> Int {
        _storage.index(before: i)
    }

    @inlinable
    public func itemAt(index: Int) -> UInt8 {
        _storage.itemAt(index: index)
    }

    @inlinable
    public mutating func setItemAt(index: Int, element: UInt8) {
        _storage.setItemAt(index: index, element: element)
    }

    @inlinable
    public mutating func swapAt(_ i: Int, _ j: Int) {
        _storage.swapAt(i, j)
    }

    @inlinable
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        for i in indices {
            buffer[index] = itemAt(index: i)
            index += 1
        }
    }

    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws(SocketError) {
        try await _storage.write(to: socket)
    }
}
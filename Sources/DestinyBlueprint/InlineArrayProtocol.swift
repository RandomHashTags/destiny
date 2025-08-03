
public protocol InlineArrayProtocol: InlineCollectionProtocol, ~Copyable where Index == Int {
    init(repeating value: Element)
}

// MARK Conformances
extension InlineArray: InlineArrayProtocol, HTTPSocketWritable {
    @inlinable
    public func itemAt(index: Index) -> Element {
        self[index]
    }

    @inlinable
    public mutating func setItemAt(index: Int, element: Element) {
        self[index] = element
    }

    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try withUnsafePointer(to: self, {
            try socket.writeBuffer($0, length: count)
        })
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
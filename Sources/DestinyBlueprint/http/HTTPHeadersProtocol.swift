
/// Storage for an HTTP Message's headers.
public protocol HTTPHeadersProtocol: Sequence, Sendable where Element == (key: String, value: String) {
    associatedtype Key:Sendable
    associatedtype Value:Sendable

    subscript(_ header: Key) -> Value? { get set }
    subscript(_ header: Key) -> String? { get set }

    subscript(_ header: String) -> Value? { get set }
    subscript(_ header: String) -> String? { get set }

    /// Whether or not the given header exists.
    func has(_ header: Key) -> Bool

    /// Whether or not the given header, as a `String`, exists.
    func has(_ header: String) -> Bool
}

/// Default iterator for `HTTPHeadersProtocol`.
public struct HTTPHeadersProtocolIterator: IteratorProtocol {
    @usableFromInline
    let headers:[(key: String, value: String)]

    @usableFromInline
    var index:UInt16

    @usableFromInline
    let maxIndex:UInt16

    public init(
        headers: [(key: String, value: String)]
    ) {
        self.headers = headers
        index = 0
        maxIndex = UInt16(headers.count)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func next() -> (key: String, value: String)? {
        if self.index == maxIndex {
            return nil
        }
        let (key, value) = headers[Int(self.index)]
        self.index += 1
        return (key, value)
    }
}
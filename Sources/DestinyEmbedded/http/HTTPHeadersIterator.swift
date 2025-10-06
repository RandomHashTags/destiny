
import UnwrapArithmeticOperators

/// Default iterator for `HTTPHeaders`.
public struct HTTPHeadersIterator: IteratorProtocol {
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
        self.index +=! 1
        return (key, value)
    }
}
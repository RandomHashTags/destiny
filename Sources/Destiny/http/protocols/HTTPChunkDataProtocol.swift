

/// A "chunk" of data when using the `Transfer-Encoding: chunked` header.
public protocol HTTPChunkDataProtocol: BufferWritable, HTTPSocketWritable, ~Copyable {
    /// Size of the chunk in bytes.
    var chunkDataCount: Int { get }
}

// MARK: Default conformance logic
extension String {
    public var chunkDataCount: Int {
        count
    }
}

extension StaticString {
    public var chunkDataCount: Int {
        utf8CodeUnitCount
    }
}

// MARK: Conformances
extension String: HTTPChunkDataProtocol {}
extension StaticString: HTTPChunkDataProtocol {}
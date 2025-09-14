
public protocol HTTPChunkDataProtocol: BufferWritable, HTTPSocketWritable, ~Copyable {
    /// Size of the chunk in bytes.
    var chunkDataCount: Int { get }
}

// MARK: Default conformances
extension String: HTTPChunkDataProtocol {
    #if Inlinable
    @inlinable
    #endif
    public var chunkDataCount: Int {
        count
    }
}

extension StaticString: HTTPChunkDataProtocol {
    #if Inlinable
    @inlinable
    #endif
    public var chunkDataCount: Int {
        utf8CodeUnitCount
    }
}
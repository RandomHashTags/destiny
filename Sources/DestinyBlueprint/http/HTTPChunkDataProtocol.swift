
public protocol HTTPChunkDataProtocol: BufferWritable, HTTPSocketWritable, ~Copyable {
    var chunkDataCount: Int { get }
}

// MARK: Default conformances
extension String: HTTPChunkDataProtocol {
    @inlinable public var chunkDataCount: Int { count }
}

extension StaticString: HTTPChunkDataProtocol {
    @inlinable public var chunkDataCount: Int { self.utf8CodeUnitCount }
}
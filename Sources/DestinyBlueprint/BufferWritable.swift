
public protocol BufferWritable: Sendable, ~Copyable {
    mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws
}

// MARK: Default conformances
extension String: BufferWritable {
    @inlinable
    public mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        withUTF8 {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

extension StaticString: BufferWritable {
    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        self.withUTF8Buffer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}
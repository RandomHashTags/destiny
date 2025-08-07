
/// Types conforming to this protocol can write its contents to an `UnsafeMutableBufferPointer<UInt8>`.
public protocol BufferWritable: Sendable, ~Copyable {
    mutating func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) throws(BufferWriteError)
}

// MARK: Default conformances
extension String: BufferWritable {
    @inlinable
    public mutating func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        withUTF8 {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

extension StaticString: BufferWritable {
    @inlinable
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        self.withUTF8Buffer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}

extension [UInt8]: BufferWritable {
    @inlinable
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        self.withUnsafeBufferPointer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}
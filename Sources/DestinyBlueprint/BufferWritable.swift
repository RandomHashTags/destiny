
/// Types conforming to this protocol can write its contents to an `UnsafeMutableBufferPointer<UInt8>`.
public protocol BufferWritable: Sendable, ~Copyable {
    mutating func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) throws(BufferWriteError)
}

// MARK: Default conformances
extension String: BufferWritable {
    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        buffer.copyBuffer(baseAddress: utf8Start, count: utf8CodeUnitCount, at: &index)
    }
}

extension [UInt8]: BufferWritable {
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        self.withUnsafeBufferPointer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}

/// Types conforming to this protocol can write its contents to an `UnsafeMutableBufferPointer<UInt8>`.
public protocol BufferWritable: Sendable, ~Copyable {
    /// Writes contents of `self` to a buffer at the given index.
    /// 
    /// - Throws: `DestinyError`
    mutating func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) throws(DestinyError)
}

// MARK: Default conformances
extension String: BufferWritable {
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
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        buffer.copyBuffer(baseAddress: utf8Start, count: utf8CodeUnitCount, at: &index)
    }
}

extension [UInt8]: BufferWritable {
    public func write(
        to buffer: UnsafeMutableBufferPointer<UInt8>,
        at index: inout Int
    ) {
        self.withUnsafeBufferPointer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}
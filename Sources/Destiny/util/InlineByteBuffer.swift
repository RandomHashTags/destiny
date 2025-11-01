
/// A byte buffer that is backed by an `InlineArray`.
public struct InlineByteBuffer<let count: Int>: Sendable, ~Copyable {
    /// Byte buffer storage.
    public let buffer:InlineArray<count, UInt8>

    /// The actual "end" of the byte buffer data.
    public let endIndex:Int

    package init(buffer: InlineArray<count, UInt8>, endIndex: Int) {
        self.buffer = buffer
        self.endIndex = endIndex
    }

    func copy() -> Self {
        Self(buffer: buffer, endIndex: endIndex)
    }
}
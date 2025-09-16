
/// A byte buffer that is backed by an `InlineArray`.
public struct InlineByteBuffer<let count: Int>: Sendable, ~Copyable {
    @usableFromInline
    package let buffer:InlineArray<count, UInt8>

    @usableFromInline
    package let endIndex:Int

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package init(buffer: InlineArray<count, UInt8>, endIndex: Int) {
        self.buffer = buffer
        self.endIndex = endIndex
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    func copy() -> Self {
        Self(buffer: buffer, endIndex: endIndex)
    }
}
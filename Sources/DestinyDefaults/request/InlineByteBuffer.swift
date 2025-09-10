
/// A byte buffer that is backed by an `InlineArray`.
public struct InlineByteBuffer<let count: Int>: Sendable, ~Copyable {
    @usableFromInline
    let buffer:InlineArray<count, UInt8>

    @usableFromInline
    let endIndex:Int

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    init(buffer: InlineArray<count, UInt8>, endIndex: Int) {
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

// MARK: Copyable
// needed for `AsyncStream` and continuations
@usableFromInline
struct CopyableInlineBuffer<let count: Int>: Sendable {
    @usableFromInline
    let buffer:InlineArray<count, UInt8>

    @usableFromInline
    let endIndex:Int

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    init(buffer: InlineArray<count, UInt8>, endIndex: Int) {
        self.buffer = buffer
        self.endIndex = endIndex
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    func noncopyable() -> InlineByteBuffer<count> {
        .init(buffer: buffer, endIndex: endIndex)
    }
}
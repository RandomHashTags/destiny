
#if RequestBodyStream

import DestinyEmbedded

/// Needed for `AsyncStream` and continuations
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

#endif
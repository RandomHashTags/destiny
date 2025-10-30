
#if RequestBodyStream

import DestinyEmbedded

/// Needed for `AsyncStream` and continuations
@usableFromInline
struct CopyableInlineBuffer<let count: Int>: Sendable {
    @usableFromInline
    let buffer:InlineArray<count, UInt8>

    @usableFromInline
    let endIndex:Int

    init(buffer: InlineArray<count, UInt8>, endIndex: Int) {
        self.buffer = buffer
        self.endIndex = endIndex
    }

    func noncopyable() -> InlineByteBuffer<count> {
        .init(buffer: buffer, endIndex: endIndex)
    }
}

#endif

#if NonEmbedded && RequestBodyStream

/// Needed for `AsyncStream` and continuations
@usableFromInline
struct CopyableInlineBuffer<let count: Int>: Sendable {
    @usableFromInline
    let buffer:[count of UInt8]

    @usableFromInline
    let endIndex:Int

    init(buffer: [count of UInt8], endIndex: Int) {
        self.buffer = buffer
        self.endIndex = endIndex
    }

    func noncopyable() -> InlineByteBuffer<count> {
        .init(buffer: buffer, endIndex: endIndex)
    }
}

#endif
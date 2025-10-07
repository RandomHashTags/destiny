
#if CopyableDateHeaderPayload

import DestinyEmbedded

public struct DateHeaderPayload: @unchecked Sendable {
    @usableFromInline let preDatePointer:UnsafePointer<UInt8>
    @usableFromInline let preDatePointerCount:Int
    @usableFromInline let postDatePointer:UnsafePointer<UInt8>
    @usableFromInline let postDatePointerCount:Int

    public init(
        preDate: StaticString,
        postDate: StaticString
    ) {
        self.preDatePointer = preDate.utf8Start
        self.preDatePointerCount = preDate.utf8CodeUnitCount
        self.postDatePointer = postDate.utf8Start
        self.postDatePointerCount = postDate.utf8CodeUnitCount
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func write(to socket: some FileDescriptor) throws(ResponderError) {
        do throws(SocketError) {
            try socket.writeBuffers3(
                (preDatePointer, preDatePointerCount),
                (HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, HTTPDateFormat.InlineArrayResult.count),
                (postDatePointer, postDatePointerCount)
            )
        } catch {
            throw .socketError(error)
        }
    }
}

#endif
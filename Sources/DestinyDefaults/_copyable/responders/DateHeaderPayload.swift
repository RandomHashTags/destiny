
#if CopyableDateHeaderPayload

import DestinyEmbedded

/// Default storage to efficiently handle the `date` header payload for responders.
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

    /// Efficiently writes the `preDate` value, `date` header and `postDate` value to a file descriptor.
    /// 
    /// - Throws: `ResponderError`
    public func write(to socket: some FileDescriptor) throws(ResponderError) {
        do throws(SocketError) {
            try socket.writeBuffers3(
                (preDatePointer, preDatePointerCount),
                (HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, HTTPDateFormat.count),
                (postDatePointer, postDatePointerCount)
            )
        } catch {
            throw .socketError(error)
        }
    }
}

#endif

#if CopyableDateHeaderPayload

#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

/// Default storage to efficiently handle the `date` header payload for responders.
public struct DateHeaderPayload: @unchecked Sendable {
    @usableFromInline let preDatePointer:UnsafePointer<UInt8>
    @usableFromInline let postDatePointer:UnsafePointer<UInt8>
    @usableFromInline let preDateIovec:iovec
    @usableFromInline let postDateIovec:iovec

    public init(
        preDate: StaticString,
        postDate: StaticString
    ) {
        self.preDatePointer = preDate.utf8Start
        self.postDatePointer = postDate.utf8Start
        self.preDateIovec = .init(iov_base: .init(mutating: preDate.utf8Start), iov_len: preDate.utf8CodeUnitCount)
        self.postDateIovec = .init(iov_base: .init(mutating: postDate.utf8Start), iov_len: postDate.utf8CodeUnitCount)
    }

    /// Efficiently writes the `preDate` value, `date` header and `postDate` value to a file descriptor.
    /// 
    /// - Throws: `DestinyError`
    public func write(to socket: some FileDescriptor) throws(DestinyError) {
        try socket.writeBuffers3(
            preDateIovec,
            HTTPDateFormat.nowIovec,
            postDateIovec
        )
    }
}

#endif

#if NonCopyableDateHeaderPayload

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
public struct NonCopyableDateHeaderPayloadWithBody<let count: Int>: @unchecked Sendable, ~Copyable {
    @usableFromInline let preDatePointer:UnsafePointer<UInt8>
    @usableFromInline let postDatePointer:UnsafePointer<UInt8>
    @usableFromInline let preDateIovec:iovec
    @usableFromInline let postDateIovec:iovec
    @usableFromInline let body:[count of UInt8]

    public init(
        preDate: StaticString,
        postDate: StaticString,
        body: [count of UInt8]
    ) {
        self.preDatePointer = preDate.utf8Start
        self.postDatePointer = postDate.utf8Start
        self.preDateIovec = .init(iov_base: .init(mutating: preDate.utf8Start), iov_len: preDate.utf8CodeUnitCount)
        self.postDateIovec = .init(iov_base: .init(mutating: postDate.utf8Start), iov_len: postDate.utf8CodeUnitCount)
        self.body = body
    }

    package init(
        _ payload: borrowing Self
    ) {
        self.preDatePointer = payload.preDatePointer
        self.postDatePointer = payload.postDatePointer
        self.preDateIovec = payload.preDateIovec
        self.postDateIovec = payload.postDateIovec
        self.body = payload.body
    }

    /// Efficiently writes the `preDate` value, `date` header and `postDate` value to a file descriptor.
    /// 
    /// - Throws: `DestinyError`
    public func write(to socket: some FileDescriptor) throws(DestinyError) {
        do { // TODO: fix
            try body.span.withUnsafeBufferPointer {
                try socket.writeBuffers4(
                    preDateIovec,
                    HTTPDateFormat.nowIovec,
                    postDateIovec,
                    .init(iov_base: .init(mutating: $0.baseAddress), iov_len: $0.count)
                )
            }
        } catch {
            throw .custom("\(error)")
        }
    }
}

#endif
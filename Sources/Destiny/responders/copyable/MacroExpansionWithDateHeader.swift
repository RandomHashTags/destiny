
#if CopyableMacroExpansionWithDateHeader

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

public struct MacroExpansionWithDateHeader: Sendable {
    public static let bodyCountSuffix:iovec = {
        let ss:StaticString = "\r\n\r\n"
        return .init(iov_base: .init(mutating: ss.utf8Start), iov_len: ss.utf8CodeUnitCount)
    }()

    public let bodyCount:String.UTF8View
    public let body:String.UTF8View
    public let payload:DateHeaderPayload

    public init(_ value: StaticString, body: String) {
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
        payload = .init(preDate: "", postDate: value)
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: String
    ) {
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
        payload = .init(preDate: preDateValue, postDate: postDateValue)
    }
}

// MARK: Respond
extension MacroExpansionWithDateHeader {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        var err:DestinyError? = nil
        bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
            body.withContiguousStorageIfAvailable { bodyPointer in
                do throws(DestinyError) {
                    try request.fileDescriptor.writeBuffers6(
                        payload.preDateIovec,
                        HTTPDateFormat.nowIovec,
                        payload.postDateIovec,
                        (bodyCountPointer.baseAddress!, bodyCountPointer.count),
                        Self.bodyCountSuffix,
                        (bodyPointer.baseAddress!, bodyPointer.count),
                    )
                } catch {
                    err = error
                }
            }
        }
        request.fileDescriptor.flush(provider: provider)
        if let err {
            throw err
        }
    }
}

#if Protocols

// MARK: Conformances
extension MacroExpansionWithDateHeader: RouteResponderProtocol {}

#endif

#endif
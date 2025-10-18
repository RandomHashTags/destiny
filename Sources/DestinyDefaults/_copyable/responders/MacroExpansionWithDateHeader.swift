
#if CopyableMacroExpansionWithDateHeader

import DestinyEmbedded

public struct MacroExpansionWithDateHeader: Sendable {
    public static let bodyCountSuffix:StaticString = "\r\n\r\n"

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
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
            body.withContiguousStorageIfAvailable { bodyPointer in
                do throws(SocketError) {
                    try socket.writeBuffers6(
                        (payload.preDatePointer, payload.preDatePointerCount),
                        (HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, HTTPDateFormat.count),
                        (payload.postDatePointer, payload.postDatePointerCount),
                        (bodyCountPointer.baseAddress!, bodyCountPointer.count),
                        (Self.bodyCountSuffix.utf8Start, Self.bodyCountSuffix.utf8CodeUnitCount),
                        (bodyPointer.baseAddress!, bodyPointer.count),
                    )
                } catch {
                    err = error
                }
            }
        }
        if let err {
            throw .socketError(err)
        }
        completionHandler()
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension MacroExpansionWithDateHeader: StaticRouteResponderProtocol {}

#endif

#endif
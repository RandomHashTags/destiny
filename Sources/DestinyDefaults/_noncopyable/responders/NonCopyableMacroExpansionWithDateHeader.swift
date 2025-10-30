
#if NonCopyableMacroExpansionWithDateHeader

import DestinyEmbedded

public struct NonCopyableMacroExpansionWithDateHeader: Sendable, ~Copyable {
    public static let bodyCountSuffix:StaticString = "\r\n\r\n"

    public let bodyCount:String.UTF8View
    public let body:String.UTF8View
    public let payload:NonCopyableDateHeaderPayload

    public init(_ value: StaticString, body: String) {
        payload = .init(preDate: "", postDate: value)
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: String
    ) {
        payload = .init(preDate: preDateValue, postDate: postDateValue)
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
    }
}

// MARK: Respond
extension NonCopyableMacroExpansionWithDateHeader {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    public func respond(
        socket: some FileDescriptor,
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
extension NonCopyableMacroExpansionWithDateHeader: NonCopyableRouteResponderProtocol {
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif
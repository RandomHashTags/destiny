
#if CopyableMacroExpansionWithDateHeader

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
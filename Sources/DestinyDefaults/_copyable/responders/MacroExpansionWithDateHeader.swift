
#if CopyableMacroExpansionWithDateHeader

import DestinyBlueprint

public struct MacroExpansionWithDateHeader: Sendable {
    public static let bodyCountSuffix:StaticString = "\r\n\r\n"

    public let preDateValue:StaticString
    public let postDateValue:StaticString
    public let bodyCount:String.UTF8View
    public let body:String.UTF8View

    public init(_ value: StaticString, body: String) {
        preDateValue = ""
        postDateValue = value
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: String
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        bodyCount = String(body.utf8Span.count).utf8
        self.body = body.utf8
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
        HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
            bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                body.withContiguousStorageIfAvailable { bodyPointer in
                    do throws(SocketError) {
                        try socket.writeBuffers([
                            (preDateValue.utf8Start, preDateValue.utf8CodeUnitCount),
                            (datePointer.baseAddress!, datePointer.count),
                            (postDateValue.utf8Start, postDateValue.utf8CodeUnitCount),
                            (bodyCountPointer.baseAddress!, bodyCountPointer.count),
                            (Self.bodyCountSuffix.utf8Start, Self.bodyCountSuffix.utf8CodeUnitCount),
                            (bodyPointer.baseAddress!, bodyPointer.count),
                        ])
                    } catch {
                        err = error
                    }
                }
            }
        }
        if let err {
            throw .socketError(err)
        }
        completionHandler()
    }
}

// MARK: Conformances
extension MacroExpansionWithDateHeader: StaticRouteResponderProtocol {}

#endif
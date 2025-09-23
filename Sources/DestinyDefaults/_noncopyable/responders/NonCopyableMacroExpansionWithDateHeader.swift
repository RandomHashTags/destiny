
#if NonCopyable

import DestinyBlueprint

public struct NonCopyableMacroExpansionWithDateHeader: Sendable, ~Copyable {
    public let preDateValue:StaticString
    public let postDateValue:StaticString
    public let bodyCount:String.UTF8View
    public let body:String.UTF8View

    public init(_ value: StaticString, body: String) {
        preDateValue = ""
        postDateValue = value
        bodyCount = String(body.count).utf8
        self.body = body.utf8
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: String
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        bodyCount = String(body.count).utf8
        self.body = body.utf8
    }
}

// MARK: Write to socket
extension NonCopyableMacroExpansionWithDateHeader: NonCopyableStaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        preDateValue.withUTF8Buffer { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withUTF8Buffer { postDatePointer in
                    bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                        let bodyCountSuffix:InlineArray<4, UInt8> = [.carriageReturn, .lineFeed, .carriageReturn, .lineFeed]
                        bodyCountSuffix.span.withUnsafeBufferPointer { bodyCountSuffixPointer in
                            body.withContiguousStorageIfAvailable { bodyPointer in
                                do throws(SocketError) {
                                    try socket.writeBuffers([
                                        preDatePointer,
                                        datePointer,
                                        postDatePointer,
                                        bodyCountPointer,
                                        bodyCountSuffixPointer,
                                        bodyPointer
                                    ])
                                } catch {
                                    err = error
                                }
                            }
                        }
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

#endif
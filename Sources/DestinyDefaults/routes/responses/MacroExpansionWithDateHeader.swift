
import DestinyBlueprint

public struct MacroExpansionWithDateHeader {
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
extension MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func write(
        to socket: Int32
    ) throws(SocketError) {
        var err:SocketError? = nil
        preDateValue.withUTF8Buffer { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withUTF8Buffer { postDatePointer in
                    bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                        let bodyCountSuffix:InlineArray<4, UInt8> = [.carriageReturn, .lineFeed, .carriageReturn, .lineFeed]
                        bodyCountSuffix.span.withUnsafeBufferPointer { bodyCountSuffixPointer in
                            body.withContiguousStorageIfAvailable { bodyPointer in
                                do throws(SocketError) {
                                    try socket.socketWriteBuffers([
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
        socket.socketClose()
        if let err {
            throw err
        }
    }
}
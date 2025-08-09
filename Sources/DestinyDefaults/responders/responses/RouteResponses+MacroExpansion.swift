
import DestinyBlueprint

extension RouteResponses {
    public struct MacroExpansion: StaticRouteResponderProtocol {
        public let value:StaticString
        public let bodyCount:String.UTF8View
        public let body:String.UTF8View

        public init(_ value: StaticString, body: String) {
            self.value = value
            bodyCount = String(body.count).utf8
            self.body = body.utf8
        }

        @inlinable
        public func write(
            to socket: Int32
        ) throws(SocketError) {
            var err:SocketError? = nil
            value.withUTF8Buffer { valuePointer in
                bodyCount.withContiguousStorageIfAvailable { bodyCountPointer in
                    body.withContiguousStorageIfAvailable { bodyPointer in
                        let bodyCountSuffix:InlineArray<4, UInt8> = [.carriageReturn, .lineFeed, .carriageReturn, .lineFeed]
                        bodyCountSuffix.span.withUnsafeBufferPointer { bodyCountSuffixPointer in
                            do throws(SocketError) {
                                try socket.socketWriteBuffers([
                                    valuePointer,
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
            socket.socketClose()
            if let err {
                throw err
            }
        }
    }
}

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
        public func respond(
            router: some HTTPRouterProtocol,
            socket: Int32,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
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
            if let err {
                throw err
            }
            completionHandler()
        }
    }
}
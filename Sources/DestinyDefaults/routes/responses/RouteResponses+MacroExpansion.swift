
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
            to socket: borrowing some HTTPSocketProtocol & ~Copyable
        ) async throws(SocketError) {
            var err:SocketError? = nil
            value.withUTF8Buffer { valuePointer in
                bodyCount.withContiguousStorageIfAvailable { contentLengthPointer in
                    body.withContiguousStorageIfAvailable { bodyPointer in
                        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                            var i = 0
                            buffer.copyBuffer(valuePointer, at: &i)
                            contentLengthPointer.forEach {
                                buffer[i] = $0
                                i += 1
                            }
                            buffer[i] = .carriageReturn
                            i += 1
                            buffer[i] = .lineFeed
                            i += 1
                            buffer[i] = .carriageReturn
                            i += 1
                            buffer[i] = .lineFeed
                            i += 1
                            buffer.copyBuffer(bodyPointer, at: &i)
                            do throws(SocketError) {
                                try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                                return
                            } catch {
                                err = error
                            }
                        })
                    }
                }
            }
            if let err {
                throw err
            }
        }
    }
}

import DestinyBlueprint

extension RouteResponses {
    public struct MacroExpansion: StaticRouteResponderProtocol {
        public let value:String
        public let body:String

        public init(_ value: String, body: String) {
            self.value = value
            self.body = body
        }
        public init(_ response: HTTPResponseMessage) {
            value = (try? response.string(escapeLineBreak: true)) ?? ""
            if let b = response.body {
                body = "\(b)"
            } else {
                body = ""
            }
        }

        @inlinable
        public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
            try value.utf8.withContiguousStorageIfAvailable { valuePointer in
                try String(body.count).utf8.withContiguousStorageIfAvailable { contentLengthPointer in
                    try body.utf8.withContiguousStorageIfAvailable { bodyPointer in
                        try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
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
                            try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                        })
                    }
                }
            }
        }
    }
}
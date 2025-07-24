
import DestinyBlueprint

extension RouteResponses {
    public struct MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
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
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.utf8.withContiguousStorageIfAvailable { valuePointer in
                try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                    try String(body.count).utf8.withContiguousStorageIfAvailable { contentLengthPointer in
                        try body.utf8.withContiguousStorageIfAvailable { bodyPointer in
                            try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                                var i = 0
                                buffer.copyBuffer(valuePointer, at: &i)
                                // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                                var offset = 20
                                for i in 0..<HTTPDateFormat.InlineArrayResult.count {
                                    buffer[offset] = datePointer[i]
                                    offset += 1
                                }
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
}
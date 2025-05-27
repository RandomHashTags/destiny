
import DestinyBlueprint

extension RouteResponses {
    public struct MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
        public let value:Swift.String
        public let body:Swift.String

        public init(_ value: Swift.String, body: Swift.String) {
            self.value = value
            self.body = body
        }
        public init(_ response: HTTPResponseMessage, fromMacro: Bool) {
            value = (try? response.string(escapeLineBreak: true, fromMacro: fromMacro)) ?? ""
            body = response.body?.debugDescription ?? ""
        }

        public var debugDescription: Swift.String {
            """
            RouteResponses.MacroExpansionWithDateHeader(
                "\(value)",
                body: \(body)")
            )
            """
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.utf8.withContiguousStorageIfAvailable { valuePointer in
                try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                    try Swift.String(body.count).utf8.withContiguousStorageIfAvailable { contentLengthPointer in
                        try body.utf8.withContiguousStorageIfAvailable { bodyPointer in
                            try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                                var i = 0
                                // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                                while i < 20 {
                                    buffer[i] = valuePointer[i]
                                    i += 1
                                }
                                datePointer.forEach {
                                    buffer[i] = $0
                                    i += 1
                                }
                                while i < valuePointer.count {
                                    buffer[i] = valuePointer[i]
                                    i += 1
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
                                bodyPointer.forEach {
                                    buffer[i] = $0
                                    i += 1
                                }
                                try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                            })
                        }
                    }
                }
            }
        }
    }
}
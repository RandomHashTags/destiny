
import DestinyBlueprint

extension RouteResponses {
    public struct StringWithDateHeader: StaticRouteResponderProtocol {
        public let value:Swift.StaticString

        public init(_ value: Swift.StaticString) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.StringWithDateHeader(\"" + value.description + "\")"
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            var err:(any Error)? = nil
            value.withUTF8Buffer { valuePointer in
                do {
                    try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                        try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
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
                            try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                        })
                    }
                } catch {
                    err = error
                }
            }
            if let err {
                throw err
            }
        }
    }
}
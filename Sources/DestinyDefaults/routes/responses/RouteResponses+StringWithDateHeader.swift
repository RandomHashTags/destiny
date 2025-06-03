
import DestinyBlueprint

extension RouteResponses {
    public struct StringWithDateHeader: StaticRouteResponderProtocol {
        public let value:Swift.String

        public init(_ value: Swift.String) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            return "RouteResponses.StringWithDateHeader(\"\(value)\")"
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.utf8.span.withUnsafeBufferPointer { valuePointer in
                try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                    try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
                        buffer.copyBuffer(valuePointer, at: 0)
                        // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                        var i = 20
                        datePointer.forEach {
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
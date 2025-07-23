
import DestinyBlueprint

extension RouteResponses {
    public struct UInt8Array: StaticRouteResponderProtocol {
        public let value:[UInt8]

        public init(_ value: [UInt8]) {
            self.value = value
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}
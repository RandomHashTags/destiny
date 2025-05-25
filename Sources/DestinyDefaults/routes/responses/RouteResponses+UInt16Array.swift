
import DestinyBlueprint

extension RouteResponses {
    public struct UInt16Array: StaticRouteResponderProtocol {
        public let value:[UInt16]

        public init(_ value: [UInt16]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.UInt16Array(\(value))"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBufferPointer {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}
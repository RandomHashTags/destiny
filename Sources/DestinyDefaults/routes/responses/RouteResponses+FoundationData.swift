
#if canImport(FoundationEssentials) || canImport(Foundation)
import DestinyBlueprint

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

extension RouteResponses {
    public struct FoundationData: StaticRouteResponderProtocol {
        public let value:Data

        public init(_ value: Data) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "RouteResponses.FoundationData(\(value))"
        }

        @inlinable
        public func respond<T: SocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.withUnsafeBytes {
                try socket.writeBuffer($0.baseAddress!, length: value.count)
            }
        }
    }
}

#endif
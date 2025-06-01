
import DestinyBlueprint

extension RouteResponses {
    public struct String: StaticRouteResponderProtocol {
        public let value:Swift.String

        public init(_ value: Swift.String) {
            self.value = value
        }
        public init(_ response: HTTPResponseMessage) {
            value = (try? response.string(escapeLineBreak: true)) ?? ""
        }

        public var debugDescription: Swift.String {
            "RouteResponses.String(\"" + value + "\")"
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try value.utf8.withContiguousStorageIfAvailable {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            }
        }
    }
}

import DestinyBlueprint

public enum RouteResponses {
}

/*
// MARK: UnsafeBufferPointer
extension RouteResponses {
    public struct UnsafeBufferPointer: @unchecked Sendable, StaticRouteResponderProtocol {
        public let value:Swift.UnsafeBufferPointer<UInt8>
        public init(_ value: Swift.UnsafeBufferPointer<UInt8>) {
            self.value = value
        }

        @inlinable
        public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
            try socket.writeBuffer(value.baseAddress!, length: value.count)
        }
    }
}*/

// MARK: InlineArray
extension InlineArray where Element == UInt8 {
    @inlinable
    public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try span.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }

    public var debugDescription: String {
        return "[" + indices.map({ String(self.itemAt(index: $0)) }).joined(separator: ", ") + "]"
    }
}
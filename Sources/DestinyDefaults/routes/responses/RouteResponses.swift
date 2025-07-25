
import DestinyBlueprint

public enum RouteResponses {
}

// MARK: InlineArray
extension InlineArray where Element == UInt8 {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try span.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }

    public var debugDescription: String {
        return "[" + indices.map({ String(self.itemAt(index: $0)) }).joined(separator: ", ") + "]"
    }
}
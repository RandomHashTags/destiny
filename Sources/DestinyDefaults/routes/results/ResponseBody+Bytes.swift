
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func bytes(_ value: [UInt8]) -> Self.Bytes {
        Self.Bytes(value)
    }
    public struct Bytes: ResponseBodyProtocol, CustomStringConvertible {
        public let value:[UInt8]

        @inlinable
        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var description: String {
            "ResponseBody.Bytes(\(value))"
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> String {
            .init(decoding: value, as: UTF8.self)
        }

        @inlinable
        public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
            value.withUnsafeBufferPointer { p in
                buffer.copyBuffer(p, at: &index)
            }
        }

        @inlinable public var hasDateHeader: Bool { false }
    }
}

extension ResponseBody.Bytes: StaticRouteResponderProtocol {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try value.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
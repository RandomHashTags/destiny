
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func bytes(_ value: [UInt8]) -> Self.Bytes {
        Self.Bytes(value)
    }
    public struct Bytes: ResponseBodyProtocol {
        public let value:[UInt8]

        @inlinable
        public init(_ value: [UInt8]) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.bytes(\(value))"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.UInt8Array(\(value))"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            Self([UInt8](input.utf8)).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: false))
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> Swift.String {
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
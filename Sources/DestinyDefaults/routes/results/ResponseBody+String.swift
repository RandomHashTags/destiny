
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func string(_ value: Swift.String) -> String {
        Self.String(value)
    }

    public struct String: ResponseBodyProtocol {
        public let value:Swift.String

        @inlinable
        public init(_ value: Swift.String) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.string(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.String(\"\(value)\")"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            Self(input).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable
        public var count: Int {
            value.utf8.count
        }
        
        @inlinable
        public func string() -> Swift.String {
            value
        }

        @inlinable
        public func bytes() -> [UInt8] {
            [UInt8](value.utf8)
        }

        @inlinable
        public func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
            try InlineVLArray<UInt8>.create(string: value, closure)
        }

        @inlinable public var hasDateHeader: Bool { false }
    }
}
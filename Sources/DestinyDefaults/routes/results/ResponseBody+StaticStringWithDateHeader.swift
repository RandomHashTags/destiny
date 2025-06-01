
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func staticStringWithDateHeader(_ value: Swift.StaticString) -> StaticStringWithDateHeader {
        Self.StaticStringWithDateHeader(value)
    }

    public struct StaticStringWithDateHeader: ResponseBodyProtocol {
        public var value:Swift.StaticString

        @inlinable
        public init(_ value: Swift.StaticString) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.staticStringWithDateHeader(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.StaticStringWithDateHeader(\"\(value)\")"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            fatalError("cannot do that")
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable
        public var count: Int {
            value.utf8CodeUnitCount
        }
        
        @inlinable
        public func string() -> Swift.String {
            value.description
        }

        @inlinable
        public func bytes() -> [UInt8] {
            [UInt8](value.description.utf8)
        }

        @inlinable
        public func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
            try InlineVLArray<UInt8>.create(string: value, closure)
        }

        @inlinable public var hasDateHeader: Bool { true }
    }
}
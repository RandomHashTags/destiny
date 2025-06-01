
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansion<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansion<Value> {
        Self.MacroExpansion(value)
    }

    public struct MacroExpansion<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public let value:Value

        @inlinable
        public init(_ value: Value) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.macroExpansion(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.MacroExpansion(\"\(value))"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            MacroExpansion<Swift.String>(input).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> Swift.String {
            value.string()
        }

        @inlinable
        public func bytes() -> [UInt8] {
            value.bytes()
        }

        @inlinable
        public func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
            try InlineVLArray<UInt8>.create(string: value.string(), closure)
        }

        @inlinable public var hasDateHeader: Bool { false }

        @inlinable public var hasCustomInitializer: Bool { true }

        @inlinable
        public func customInitializer(bodyString: Swift.String) -> Swift.String {
            "\", body: " + bodyString
        }
    }
}
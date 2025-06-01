
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansionWithDateHeader<Value> {
        Self.MacroExpansionWithDateHeader(value)
    }

    public struct MacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public let value:Value

        @inlinable
        public init(_ value: Value) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.macroExpansionWithDateHeader(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.MacroExpansionWithDateHeader(\"\(value))"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            MacroExpansionWithDateHeader<Swift.String>(input).responderDebugDescription
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

        @inlinable public var hasDateHeader: Bool { true }

        @inlinable public var hasCustomInitializer: Bool { true }

        @inlinable
        public func customInitializer(bodyString: Swift.String) -> Swift.String {
            "\", body: " + bodyString
        }
    }
}
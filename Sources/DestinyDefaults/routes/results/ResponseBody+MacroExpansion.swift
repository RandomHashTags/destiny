
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
        public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
            var s = value.string()
            s.withUTF8 { p in
                buffer.copyBuffer(p, at: &index)
            }
        }

        @inlinable public var hasDateHeader: Bool { false }

        @inlinable public var hasCustomInitializer: Bool { true }

        @inlinable
        public func customInitializer(bodyString: Swift.String) -> Swift.String {
            "\", body: " + bodyString
        }
    }
}
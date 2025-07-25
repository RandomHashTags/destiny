
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansionWithDateHeader<Value> {
        Self.MacroExpansionWithDateHeader(value)
    }

    public struct MacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public var value:Value

        @inlinable
        public init(_ value: Value) {
            self.value = value
        }

        public var responderDebugDescription: String {
            "MacroExpansionWithDateHeader(\"\(value))"
        }

        public func responderDebugDescription(_ input: String) -> String {
            MacroExpansionWithDateHeader<String>(input).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable
        public var count: Int {
            value.count
        }
        
        @inlinable
        public func string() -> String {
            value.string()
        }

        @inlinable
        public mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
            try value.write(to: buffer, at: &index)
        }

        @inlinable public var hasDateHeader: Bool { true }

        @inlinable
        public func customInitializer(bodyString: String) -> String? {
            "\", body: " + bodyString
        }
    }
}
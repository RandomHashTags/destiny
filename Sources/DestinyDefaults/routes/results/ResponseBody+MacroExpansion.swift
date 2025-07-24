
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

        public var responderDebugDescription: String {
            "RouteResponses.MacroExpansion(\"\(value))"
        }

        public func responderDebugDescription(_ input: String) -> String {
            MacroExpansion<String>(input).responderDebugDescription
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
        public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
            var s = value.string()
            s.withUTF8 { p in
                buffer.copyBuffer(p, at: &index)
            }
        }

        @inlinable public var hasDateHeader: Bool { false }

        @inlinable
        public func customInitializer(bodyString: String) -> String? {
            "\", body: " + bodyString
        }
    }
}
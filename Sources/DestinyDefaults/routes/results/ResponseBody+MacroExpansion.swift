
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansion<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansion<Value> {
        Self.MacroExpansion(value)
    }

    public struct MacroExpansion<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        @inlinable public static var id:UInt8 { 2 }

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

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T, fromMacro: Bool) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: true, fromMacro: fromMacro))
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
    }
}

/// Types conforming to this protocol can be used as...
public protocol ResponseBodyValueProtocol: Sendable {
    @inlinable
    var count: Int { get }

    @inlinable
    func string() -> String

    @inlinable
    func bytes() -> [UInt8]
}

extension StaticString: ResponseBodyValueProtocol {
    @inlinable
    public var count: Int {
        self.utf8CodeUnitCount
    }

    @inlinable
    public func string() -> String {
        description
    }

    @inlinable
    public func bytes() -> [UInt8] {
        Array(string().utf8)
    }

}
extension String: ResponseBodyValueProtocol {
    @inlinable
    public func string() -> String {
        self
    }

    @inlinable
    public func bytes() -> [UInt8] {
        Array(utf8)
    }
}
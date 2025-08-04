
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansion<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansion<Value> {
        Self.MacroExpansion(value)
    }

    public struct MacroExpansion<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public var value:Value

        @inlinable
        public init(_ value: Value) {
            self.value = value
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
        public mutating func write(
            to buffer: UnsafeMutableBufferPointer<UInt8>,
            at index: inout Int
        ) throws(BufferWriteError) {
            try value.write(to: buffer, at: &index)
        }
    }
}
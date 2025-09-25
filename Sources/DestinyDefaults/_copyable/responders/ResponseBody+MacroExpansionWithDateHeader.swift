
#if CopyableMacroExpansionWithDateHeader

import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func macroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansionWithDateHeader<Value> {
        .init(value)
    }

    public struct MacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public var value:Value

        #if Inlinable
        @inlinable
        #endif
        public init(_ value: Value) {
            self.value = value
        }

        #if Inlinable
        @inlinable
        #endif
        public var count: Int {
            value.count
        }
        
        #if Inlinable
        @inlinable
        #endif
        public func string() -> String {
            value.string()
        }

        #if Inlinable
        @inlinable
        #endif
        public mutating func write(
            to buffer: UnsafeMutableBufferPointer<UInt8>,
            at index: inout Int
        ) throws(BufferWriteError) {
            try value.write(to: buffer, at: &index)
        }

        #if Inlinable
        @inlinable
        #endif
        public var hasDateHeader: Bool {
            true
        }
    }
}

#endif

#if CopyableMacroExpansion

import DestinyEmbedded

extension ResponseBody {
    public struct MacroExpansion<Value: ResponseBodyValueProtocol>: Sendable {
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
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension ResponseBody.MacroExpansion: ResponseBodyProtocol {}

#endif

#endif
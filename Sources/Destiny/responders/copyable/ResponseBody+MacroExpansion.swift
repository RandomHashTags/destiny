
#if CopyableMacroExpansion


extension ResponseBody {
    public struct MacroExpansion<Value: ResponseBodyValueProtocol>: Sendable {
        public var value:Value

        public init(_ value: Value) {
            self.value = value
        }

        public var count: Int {
            value.count
        }
        
        public func string() -> String {
            value.string()
        }

        public mutating func write(
            to buffer: UnsafeMutableBufferPointer<UInt8>,
            at index: inout Int
        ) throws(BufferWriteError) {
            try value.write(to: buffer, at: &index)
        }
    }
}

#if Protocols

// MARK: Conformances
extension ResponseBody.MacroExpansion: ResponseBodyProtocol {}

#endif

#endif
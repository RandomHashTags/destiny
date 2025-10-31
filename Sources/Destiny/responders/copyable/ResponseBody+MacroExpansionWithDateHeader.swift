
#if CopyableMacroExpansionWithDateHeader

extension ResponseBody {
    public struct MacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: Sendable {
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

        public var hasDateHeader: Bool {
            true
        }
    }
}

#if Protocols

// MARK: Conformances
extension ResponseBody.MacroExpansionWithDateHeader: ResponseBodyProtocol {}

#endif

#endif
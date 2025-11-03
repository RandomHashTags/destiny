
#if NonCopyableMacroExpansionWithDateHeader

extension ResponseBody {
    public static func nonCopyableMacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>(_ value: Value) -> NonCopyableMacroExpansionWithDateHeader<Value> {
        .init(value)
    }

    public struct NonCopyableMacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: Sendable, ~Copyable {
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
        ) throws(DestinyError) {
            try value.write(to: buffer, at: &index)
        }

        public var hasDateHeader: Bool {
            true
        }
    }
}

#if Protocols

// MARK: Conformances
extension ResponseBody.NonCopyableMacroExpansionWithDateHeader: ResponseBodyProtocol {}

#endif

#endif
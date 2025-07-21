
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func macroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>(_ value: Value) -> MacroExpansionWithDateHeader<Value> {
        Self.MacroExpansionWithDateHeader(value)
    }

    public struct MacroExpansionWithDateHeader<Value: ResponseBodyValueProtocol>: ResponseBodyProtocol {
        public let value:Value

        @inlinable
        public init(_ value: Value) {
            self.value = value
        }

        public var debugDescription: Swift.String {
            "ResponseBody.macroExpansionWithDateHeader(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.MacroExpansionWithDateHeader(\"\(value))"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            MacroExpansionWithDateHeader<Swift.String>(input).responderDebugDescription
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
        }

        @inlinable public var hasDateHeader: Bool { true }

        @inlinable public var hasCustomInitializer: Bool { true }

        @inlinable
        public func customInitializer(bodyString: Swift.String) -> Swift.String {
            "\", body: " + bodyString
        }
    }
}

/*
extension ResponseBody.MacroExpansionWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    func temporaryBuffer(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        try value.utf8.withContiguousStorageIfAvailable { valuePointer in
            try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                try Swift.String(body.count).utf8.withContiguousStorageIfAvailable { contentLengthPointer in
                    try body.utf8.withContiguousStorageIfAvailable { bodyPointer in
                        try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count + contentLengthPointer.count + 4 + bodyPointer.count, { buffer in
                            var i = 0
                            buffer.copyBuffer(valuePointer, at: &i)
                            // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                            var offset = 20
                            for i in 0..<HTTPDateFormat.InlineArrayResult.count {
                                buffer[offset] = datePointer[i]
                                offset += 1
                            }
                            contentLengthPointer.forEach {
                                buffer[i] = $0
                                i += 1
                            }
                            buffer[i] = .carriageReturn
                            i += 1
                            buffer[i] = .lineFeed
                            i += 1
                            buffer[i] = .carriageReturn
                            i += 1
                            buffer[i] = .lineFeed
                            i += 1
                            buffer.copyBuffer(bodyPointer, at: &i)
                            try closure(buffer)
                        })
                    }
                }
            }
        }
    }
    @inlinable
    public func respond<Socket>(to socket: borrowing Socket) async throws where Socket : HTTPSocketProtocol, Socket : ~Copyable {
        
    }
}*/
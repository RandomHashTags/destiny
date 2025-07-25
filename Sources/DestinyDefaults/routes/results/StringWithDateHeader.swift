
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func stringWithDateHeader(_ value: String) -> StringWithDateHeader {
        StringWithDateHeader(value)
    }
}

public struct StringWithDateHeader: ResponseBodyProtocol {
    public var value:String

    @inlinable
    public init(_ value: String) {
        self.value = value
    }

    public var responderDebugDescription: String {
        "StringWithDateHeader(\"\(value)\")"
    }

    public func responderDebugDescription(_ input: String) -> String {
        Self(input).responderDebugDescription
    }

    public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }

    @inlinable
    public var count: Int {
        value.utf8.count
    }
    
    @inlinable
    public func string() -> String {
        value
    }

    @inlinable
    func temporaryBuffer(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) rethrows {
        try value.utf8.span.withUnsafeBufferPointer { valuePointer in
            try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
                    buffer.copyBuffer(valuePointer, at: 0)
                    // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                    var i = 20
                    datePointer.forEach {
                        buffer[i] = $0
                        i += 1
                    }
                    try closure(buffer)
                })
            }
        }
    }

    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        temporaryBuffer { completeBuffer in
            index = 0
            buffer.copyBuffer(completeBuffer, at: &index)
        }
    }

    @inlinable public var hasDateHeader: Bool { true }
}

extension StringWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try temporaryBuffer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
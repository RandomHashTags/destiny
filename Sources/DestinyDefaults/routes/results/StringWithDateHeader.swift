
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
            try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
                buffer.copyBuffer(valuePointer, at: 0)
                // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                var i = 20
                let dateSpan = HTTPDateFormat.shared.nowInlineArray.span
                for indice in dateSpan.indices {
                    buffer[i] = dateSpan[indice]
                    i += 1
                }
                try closure(buffer)
            })
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
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try temporaryBuffer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
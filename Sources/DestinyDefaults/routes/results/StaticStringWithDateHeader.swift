
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func staticStringWithDateHeader(_ value: StaticString) -> StaticStringWithDateHeader {
        StaticStringWithDateHeader(value)
    }
}

public struct StaticStringWithDateHeader: ResponseBodyProtocol {
    public var value:StaticString

    @inlinable
    public init(_ value: StaticString) {
        self.value = value
    }

    @inlinable
    public var count: Int {
        value.utf8CodeUnitCount
    }
    
    @inlinable
    public func string() -> String {
        value.description
    }

    @inlinable
    func temporaryBuffer(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws -> Void) throws {
        var err:(any Error)? = nil
        value.withUTF8Buffer { valuePointer in
            do {
                try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                    try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
                        var i = 0
                        // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                        while i < 20 {
                            buffer[i] = valuePointer[i]
                            i += 1
                        }
                        datePointer.forEach {
                            buffer[i] = $0
                            i += 1
                        }
                        while i < valuePointer.count {
                            buffer[i] = valuePointer[i]
                            i += 1
                        }
                        try closure(buffer)
                        return
                    })
                }
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }

    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        try temporaryBuffer { completeBuffer in
            index = 0
            buffer.copyBuffer(completeBuffer, at: &index)
        }
    }

    @inlinable public var hasDateHeader: Bool { true }
}

extension StaticStringWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try temporaryBuffer { buffer in
            try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
        }
    }
}
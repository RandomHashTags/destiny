
import DestinyBlueprint

extension ResponseBody {
    public static func stringWithDateHeader(_ value: String) -> StringWithDateHeader {
        .init(value)
    }

    public static func stringWithDateHeader(
        preDateValue: String,
        postDateValue: String,
        value: String
    ) -> StringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue, value: value)
    }
}

public struct StringWithDateHeader: ResponseBodyProtocol {
    public let preDateValue:String.UTF8View
    public let postDateValue:String.UTF8View
    public let value:String.UTF8View

    public init(_ value: String) {
        preDateValue = "".utf8
        postDateValue = "".utf8
        self.value = value.utf8
    }
    public init(
        preDateValue: String,
        postDateValue: String,
        value: String
    ) {
        self.preDateValue = preDateValue.utf8
        self.postDateValue = postDateValue.utf8
        self.value = value.utf8
    }

    @inlinable
    public var count: Int {
        value.count
    }
    
    @inlinable
    public func string() -> String {
        String(value)
    }

    @inlinable
    func temporaryBuffer<E: Error>(_ closure: (UnsafeMutableBufferPointer<UInt8>) throws(E) -> Void) rethrows {
        try value.span.withUnsafeBufferPointer { valuePointer in
            try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: valuePointer.count, { buffer in
                buffer.copyBuffer(valuePointer, at: 0)
                // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                var i = 20
                let dateSpan = HTTPDateFormat.nowInlineArray
                for indice in dateSpan.indices {
                    buffer[i] = dateSpan[indice]
                    i += 1
                }
                try closure(buffer)
            })
        }
    }

    @inlinable public var hasDateHeader: Bool { true }
}

// MARK: Write to buffer
extension StringWithDateHeader {
    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
        HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
        postDateValue.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Write to socket
extension StringWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        var err:SocketError? = nil
        preDateValue.withContiguousStorageIfAvailable { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withContiguousStorageIfAvailable { postDatePointer in
                    do throws(SocketError) {
                        try socket.writeBuffers([preDatePointer, datePointer, postDatePointer])
                    } catch {
                        err = error
                    }
                }
            }
        }
        if let err {
            throw err
        }
    }
}

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
        preDateValue.count + HTTPDateFormat.InlineArrayResult.count + postDateValue.count + value.count
    }
    
    @inlinable
    public func string() -> String {
        String(preDateValue) + HTTPDateFormat.placeholder + String(postDateValue) + String(value)
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
        value.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Write to socket
extension StringWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func write(
        to socket: Int32
    ) throws(SocketError) {
        var err:SocketError? = nil
        preDateValue.withContiguousStorageIfAvailable { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withContiguousStorageIfAvailable { postDatePointer in
                    value.withContiguousStorageIfAvailable { valuePointer in
                        do throws(SocketError) {
                            try socket.socketWriteBuffers([preDatePointer, datePointer, postDatePointer, valuePointer])
                        } catch {
                            err = error
                        }
                    }
                }
            }
        }
        socket.socketClose()
        if let err {
            throw err
        }
    }
}
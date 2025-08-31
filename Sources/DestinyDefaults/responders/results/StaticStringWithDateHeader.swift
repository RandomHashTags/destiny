
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func staticStringWithDateHeader(_ value: StaticString) -> StaticStringWithDateHeader {
        StaticStringWithDateHeader(preDateValue: "", postDateValue: value)
    }
    @inlinable
    public static func staticStringWithDateHeader(preDateValue: StaticString, postDateValue: StaticString) -> StaticStringWithDateHeader {
        StaticStringWithDateHeader(preDateValue: preDateValue, postDateValue: postDateValue)
    }
}

public struct StaticStringWithDateHeader: ResponseBodyProtocol {
    public let preDateValue:StaticString
    public let postDateValue:StaticString

    public init(_ value: StaticString) {
        self.preDateValue = ""
        self.postDateValue = value
    }

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
    }

    @inlinable
    public var count: Int {
        preDateValue.utf8CodeUnitCount + HTTPDateFormat.InlineArrayResult.count + postDateValue.count
    }
    
    @inlinable
    public func string() -> String {
        "\(preDateValue)\(HTTPDateFormat.placeholder)\(postDateValue)"
    }

    @inlinable public var hasDateHeader: Bool { true }
}

// MARK: Write to buffer
extension StaticStringWithDateHeader {
    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
        HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
        postDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Write to socket
extension StaticStringWithDateHeader: StaticRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        preDateValue.withUTF8Buffer { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withUTF8Buffer { postDatePointer in
                    do throws(SocketError) {
                        try socket.writeBuffers([preDatePointer, datePointer, postDatePointer])
                    } catch {
                        err = error
                    }
                }
            }
        }
        if let err {
            throw .socketError(err)
        }
        completionHandler()
    }
}
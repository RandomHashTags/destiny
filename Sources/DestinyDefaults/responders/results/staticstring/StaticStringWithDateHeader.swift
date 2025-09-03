
import DestinyBlueprint

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func staticStringWithDateHeader(_ value: StaticString) -> StaticStringWithDateHeader {
        .init(preDateValue: "", postDateValue: value)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func staticStringWithDateHeader(preDateValue: StaticString, postDateValue: StaticString) -> StaticStringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue)
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

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.utf8CodeUnitCount + HTTPDateFormat.InlineArrayResult.count + postDateValue.count
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        "\(preDateValue)\(HTTPDateFormat.placeholder)\(postDateValue)"
    }

    #if Inlinable
    @inlinable
    #endif
    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension StaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
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
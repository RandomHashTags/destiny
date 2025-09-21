
import DestinyBlueprint
import DestinyDefaults

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStaticStringWithDateHeader(_ value: StaticString) -> NonCopyableStaticStringWithDateHeader {
        .init(preDateValue: "", postDateValue: value)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStaticStringWithDateHeader(preDateValue: StaticString, postDateValue: StaticString) -> NonCopyableStaticStringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue)
    }
}

public struct NonCopyableStaticStringWithDateHeader: ResponseBodyProtocol, ~Copyable {
    public let preDateValue:StaticString
    public let postDateValue:StaticString

    @usableFromInline
    let payload:NonCopyableDateHeaderPayload

    public init(_ value: StaticString) {
        self.preDateValue = ""
        self.postDateValue = value
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.utf8CodeUnitCount + HTTPDateFormat.InlineArrayResult.count + postDateValue.utf8CodeUnitCount
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
extension NonCopyableStaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
        HTTPDateFormat.nowInlineArray.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
        postDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeader: NonCopyableStaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        completionHandler()
    }
}
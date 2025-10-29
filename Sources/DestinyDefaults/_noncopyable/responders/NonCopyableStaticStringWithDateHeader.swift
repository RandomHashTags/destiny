
#if NonCopyableStaticStringWithDateHeader

import DestinyEmbedded
import UnwrapArithmeticOperators

public struct NonCopyableStaticStringWithDateHeader: Sendable, ~Copyable {
    public let payload:NonCopyableDateHeaderPayload

    public init(_ value: StaticString) {
        payload = .init(
            preDate: "",
            postDate: value
        )
    }

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString
    ) {
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }

    package init(
        _ payload: borrowing NonCopyableDateHeaderPayload
    ) {
        self.payload = .init(payload)
    }

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        payload.preDatePointerCount +! HTTPDateFormat.InlineArrayResult.count +! payload.postDatePointerCount
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        "\(String(cString: payload.preDatePointer))\(HTTPDateFormat.placeholder)\(String(cString: payload.postDatePointer))"
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
        buffer.copyBuffer(baseAddress: payload.preDatePointer, count: payload.preDatePointerCount, at: &index)
        buffer.copyBuffer(baseAddress: HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, count: HTTPDateFormat.count, at: &index)
        buffer.copyBuffer(baseAddress: payload.postDatePointer, count: payload.postDatePointerCount, at: &index)
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        completionHandler()
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension NonCopyableStaticStringWithDateHeader: ResponseBodyProtocol {}
extension NonCopyableStaticStringWithDateHeader: NonCopyableStaticRouteResponderProtocol {}

#endif

#endif
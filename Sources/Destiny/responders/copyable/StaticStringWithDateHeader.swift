
#if CopyableStaticStringWithDateHeader

import UnwrapArithmeticOperators

public struct StaticStringWithDateHeader: Sendable {
    public let payload:DateHeaderPayload

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

    public var count: Int {
        payload.preDatePointerCount +! HTTPDateFormat.InlineArrayResult.count +! payload.postDatePointerCount
    }
    
    public func string() -> String {
        "\(String(cString: payload.preDatePointer))\(HTTPDateFormat.placeholder)\(String(cString: payload.postDatePointer))"
    }

    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension StaticStringWithDateHeader {
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        buffer.copyBuffer(baseAddress: payload.preDatePointer, count: payload.preDatePointerCount, at: &index)
        buffer.copyBuffer(baseAddress: HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, count: HTTPDateFormat.count, at: &index)
        buffer.copyBuffer(baseAddress: payload.postDatePointer, count: payload.postDatePointerCount, at: &index)
    }
}

// MARK: Respond
extension StaticStringWithDateHeader {
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        completionHandler()
    }
}

#if Protocols

// MARK: Conformances
extension StaticStringWithDateHeader: ResponseBodyProtocol {}
extension StaticStringWithDateHeader: RouteResponderProtocol {}

#endif

#endif
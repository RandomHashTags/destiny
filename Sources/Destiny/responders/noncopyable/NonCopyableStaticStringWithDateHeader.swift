
#if NonCopyableStaticStringWithDateHeader

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
extension NonCopyableStaticStringWithDateHeader {
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        buffer.copyBuffer(baseAddress: payload.preDatePointer, count: payload.preDatePointerCount, at: &index)
        buffer.copyBuffer(baseAddress: HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, count: HTTPDateFormat.count, at: &index)
        buffer.copyBuffer(baseAddress: payload.postDatePointer, count: payload.postDatePointerCount, at: &index)
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeader {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        try payload.write(to: request.fileDescriptor)
        if let err = request.fileDescriptor.flush(provider: provider) {
            throw .anyError(err)
        }
    }
}

#if Protocols

// MARK: Conformances
extension NonCopyableStaticStringWithDateHeader: ResponseBodyProtocol {}
extension NonCopyableStaticStringWithDateHeader: NonCopyableRouteResponderProtocol {}

#endif

#endif
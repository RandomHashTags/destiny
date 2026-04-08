
#if NonCopyableStaticStringWithDateHeader

import UnwrapArithmeticOperators

public struct NonCopyableStaticStringWithDateHeaderAndCompressedBody<let count: Int>: Sendable, ~Copyable {
    public let payload:NonCopyableDateHeaderPayloadWithBody<count>

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: [count of UInt8]
    ) {
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue,
            body: body
        )
    }

    public var count: Int {
        payload.preDateIovec.iov_len +! HTTPDateFormat.InlineArrayResult.count +! payload.postDateIovec.iov_len + count
    }
    
    public func string() -> String {
        "\(String(cString: payload.preDatePointer))\(HTTPDateFormat.placeholder)\(String(cString: payload.postDatePointer))"
    }

    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension NonCopyableStaticStringWithDateHeaderAndCompressedBody {
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        buffer.copyBuffer(baseAddress: payload.preDatePointer, count: payload.preDateIovec.iov_len, at: &index)
        buffer.copyBuffer(baseAddress: HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, count: HTTPDateFormat.count, at: &index)
        buffer.copyBuffer(baseAddress: payload.postDatePointer, count: payload.postDateIovec.iov_len, at: &index)
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeaderAndCompressedBody {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try payload.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}

#if Protocols

// MARK: Conformances
extension NonCopyableStaticStringWithDateHeaderAndCompressedBody: ResponseBodyProtocol {}
extension NonCopyableStaticStringWithDateHeaderAndCompressedBody: NonCopyableRouteResponderProtocol {}

#endif

#endif
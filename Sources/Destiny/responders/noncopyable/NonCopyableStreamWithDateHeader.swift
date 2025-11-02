
#if NonCopyableStreamWithDateHeader

import UnwrapArithmeticOperators

public struct NonCopyableStreamWithDateHeader<Body: AsyncHTTPSocketWritable & ~Copyable>: Sendable, ~Copyable {
    public let body:Body
    public let payload:NonCopyableDateHeaderPayload

    public init(
        _ body: consuming Body
    ) {
        self.body = body
        payload = .init(
            preDate: "",
            postDate: ""
        )
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: consuming Body
    ) {
        self.body = body
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

    public var hasContentLength: Bool {
        false
    }

    // MARK: Write to buffer
    public mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws(BufferWriteError) {
        // TODO: support?
    }
}

// MARK: Respond
extension NonCopyableStreamWithDateHeader {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        let fd = request.fileDescriptor
        try payload.write(to: fd)
        let body = body
        Task {
            do throws(SocketError) {
                try await body.write(to: fd)
            } catch {
                #if DEBUG
                print("NonCopyableStreamWithDateHeader;respond;error=\(error)")
                #endif
                /*if !router.respondWithError(request: &requestCopy, error: error) {
                }*/
            }
        }
    }
}

#if Protocols

// MARK: Conformances
extension NonCopyableStreamWithDateHeader: ResponseBodyProtocol {}
extension NonCopyableStreamWithDateHeader: NonCopyableRouteResponderProtocol {}

#endif

#endif

#if CopyableStreamWithDateHeader

import UnwrapArithmeticOperators

public struct StreamWithDateHeader<Body: AsyncHTTPSocketWritable>: Sendable {
    public let body:Body
    public let payload:DateHeaderPayload

    public init(
        _ body: Body
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
        body: Body
    ) {
        self.body = body
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }

    public var count: Int {
        payload.preDateIovec.iov_len +! HTTPDateFormat.InlineArrayResult.count +! payload.postDateIovec.iov_len
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
}

// MARK: Write to buffer
extension StreamWithDateHeader {
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        // TODO: support?
    }
}

// MARK: Respond
extension StreamWithDateHeader {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try payload.write(to: request.fileDescriptor)
        var requestCopy = request.copy()
        Task {
            do throws(DestinyError) {
                try await body.write(to: requestCopy.fileDescriptor)
                requestCopy.fileDescriptor.flush(provider: provider)
            } catch {
                if !router.respondWithError(provider: provider, request: &requestCopy, error: error) {
                    requestCopy.fileDescriptor.flush(provider: provider)
                }
            }
        }
    }
}

#if Protocols

// MARK: Conformances
extension StreamWithDateHeader: ResponseBodyProtocol {}
extension StreamWithDateHeader: RouteResponderProtocol {}

#endif

#endif
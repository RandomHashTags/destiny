
#if CopyableStreamWithDateHeader

import DestinyEmbedded

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func streamWithDateHeader<Body: AsyncHTTPSocketWritable>(_ body: Body) -> StreamWithDateHeader<Body> {
        .init(body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func streamWithDateHeader<Body: HTTPSocketWritable>(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: Body
    ) -> StreamWithDateHeader<Body> {
        .init(preDateValue: preDateValue, postDateValue: postDateValue, body: body)
    }
}

public struct StreamWithDateHeader<Body: AsyncHTTPSocketWritable> {
    public let preDateValue:StaticString
    public let postDateValue:StaticString
    public let body:Body

    @usableFromInline
    let payload:DateHeaderPayload

    public init(
        _ body: Body
    ) {
        preDateValue = ""
        postDateValue = ""
        self.body = body
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: Body
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        self.body = body
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

    #if Inlinable
    @inlinable
    #endif
    public var hasContentLength: Bool {
        false
    }
}

// MARK: Write to buffer
extension StreamWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        // TODO: support?
    }
}

// MARK: Respond
extension StreamWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        var requestCopy = request.copy()
        Task {
            do throws(SocketError) {
                try await body.write(to: socket)
                completionHandler()
            } catch {
                if !router.respondWithError(socket: socket, error: error, request: &requestCopy, completionHandler: completionHandler) {
                    completionHandler()
                }
            }
        }
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension StreamWithDateHeader: ResponseBodyProtocol {}
extension StreamWithDateHeader: StaticRouteResponderProtocol {}

#endif

#endif
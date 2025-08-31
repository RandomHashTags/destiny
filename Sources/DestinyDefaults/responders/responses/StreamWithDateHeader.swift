
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func streamWithDateHeader<Body: AsyncHTTPSocketWritable>(_ body: Body) -> StreamWithDateHeader<Body> {
        .init(body)
    }
    @inlinable
    public static func streamWithDateHeader<Body: HTTPSocketWritable>(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: Body
    ) -> StreamWithDateHeader<Body> {
        .init(preDateValue: preDateValue, postDateValue: postDateValue, body: body)
    }
}

public struct StreamWithDateHeader<Body: AsyncHTTPSocketWritable>: ResponseBodyProtocol {
    public let preDateValue:StaticString
    public let postDateValue:StaticString
    public let body:Body

    public init(
        _ body: Body
    ) {
        preDateValue = ""
        postDateValue = ""
        self.body = body
    }
    public init(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: Body
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        self.body = body
    }

    @inlinable
    public var count: Int {
        preDateValue.count + HTTPDateFormat.InlineArrayResult.count + postDateValue.count
    }
    
    @inlinable
    public func string() -> String {
        "\(preDateValue)\(HTTPDateFormat.placeholder)\(postDateValue)"
    }

    @inlinable public var hasDateHeader: Bool { true }

    @inlinable public var hasContentLength: Bool { false }
}

// MARK: Write to buffer
extension StreamWithDateHeader {
    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
    }
}

// MARK: Write to socket
extension StreamWithDateHeader: StaticRouteResponderProtocol {
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
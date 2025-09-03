
import DestinyBlueprint

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

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.count + HTTPDateFormat.InlineArrayResult.count + postDateValue.count
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
    }
}

// MARK: Write to socket
extension StreamWithDateHeader: StaticRouteResponderProtocol {
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
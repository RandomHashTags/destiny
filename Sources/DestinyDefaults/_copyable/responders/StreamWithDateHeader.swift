
#if CopyableStreamWithDateHeader

import DestinyEmbedded
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
        request: inout HTTPRequest,
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

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
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        let body = body
        Task {
            do throws(SocketError) {
                try await body.write(to: socket)
                completionHandler()
            } catch {
                #if DEBUG
                print("NonCopyableStreamWithDateHeader;respond;error=\(error)")
                #endif
                completionHandler() // TODO: fix
                /*if !router.respondWithError(socket: socket, error: error, request: &requestCopy, completionHandler: completionHandler) {
                    completionHandler()
                }*/
            }
        }
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension NonCopyableStreamWithDateHeader: ResponseBodyProtocol {}
extension NonCopyableStreamWithDateHeader: NonCopyableRouteResponderProtocol {}

#endif

#endif
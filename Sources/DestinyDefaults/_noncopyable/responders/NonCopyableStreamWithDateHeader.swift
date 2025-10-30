
#if NonCopyableStreamWithDateHeader

import DestinyEmbedded
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

    // MARK: Write to buffer
    #if Inlinable
    @inlinable
    #endif
    public mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws(BufferWriteError) {
        // TODO: support?
    }
}

// MARK: Respond
extension NonCopyableStreamWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
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
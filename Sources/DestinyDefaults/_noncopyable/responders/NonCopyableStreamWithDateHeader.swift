
#if NonCopyableStreamWithDateHeader

import DestinyEmbedded
import UnwrapArithmeticOperators

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStreamWithDateHeader<Body: AsyncHTTPSocketWritable & ~Copyable>(_ body: consuming Body) -> NonCopyableStreamWithDateHeader<Body> {
        .init(body)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStreamWithDateHeader<Body: HTTPSocketWritable & ~Copyable>(
        preDateValue: StaticString,
        postDateValue: StaticString,
        body: consuming Body
    ) -> NonCopyableStreamWithDateHeader<Body> {
        .init(preDateValue: preDateValue, postDateValue: postDateValue, body: body)
    }
}

public struct NonCopyableStreamWithDateHeader<Body: AsyncHTTPSocketWritable & ~Copyable>: Sendable, ~Copyable {
    public let preDateValue:StaticString
    public let postDateValue:StaticString
    public let body:Body

    @usableFromInline
    let payload:NonCopyableDateHeaderPayload

    public init(
        _ body: consuming Body
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
        body: consuming Body
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
        preDateValue.utf8CodeUnitCount +! HTTPDateFormat.InlineArrayResult.count +! postDateValue.utf8CodeUnitCount
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
        request: inout some HTTPRequestProtocol & ~Copyable,
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
extension NonCopyableStreamWithDateHeader: NonCopyableStaticRouteResponderProtocol {}

#endif

#endif
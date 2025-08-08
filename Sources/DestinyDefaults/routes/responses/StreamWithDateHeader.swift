
import DestinyBlueprint

extension ResponseBody {
    @inlinable
    public static func streamWithDateHeader<Body: HTTPSocketWritable>(_ body: Body) -> StreamWithDateHeader<Body> {
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

public struct StreamWithDateHeader<Body: HTTPSocketWritable>: ResponseBodyProtocol {
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

    @inlinable public var count: Int {
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
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
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
            throw err
        }
        try await body.write(to: socket)
    }
}
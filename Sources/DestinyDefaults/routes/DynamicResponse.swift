
import DestinyBlueprint

public struct DynamicResponse: DynamicResponseProtocol {
    public var timestamps:DynamicRequestTimestamps
    public var message:any HTTPMessageProtocol
    public var parameters:[String]

    public init(
        timestamps: DynamicRequestTimestamps = DynamicRequestTimestamps(received: .now, loaded: .now, processed: .now),
        message: any HTTPMessageProtocol,
        parameters: [String]
    ) {
        self.timestamps = timestamps
        self.message = message
        self.parameters = parameters
    }

    public var debugDescription: String {
        """
        DynamicResponse(
            message: \(message.debugDescription),
            parameters: \(parameters)
        )
        """
    }

    @inlinable
    public func parameter(at index: Int) -> String {
        parameters[index]
    }

    @inlinable
    public mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>) {
        parameters[index] = value.string()
    }
}

extension DynamicResponse {
    @inlinable
    public mutating func setHTTPVersion(_ version: HTTPVersion) {
        message.version = version
    }

    @inlinable
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        message.status = code
    }

    @inlinable
    public mutating func setHeader(key: String, value: String) {
        message.setHeader(key: key, value: value)
    }

    @inlinable
    public mutating func appendCookie<Cookie: HTTPCookieProtocol>(_ cookie: Cookie) {
        message.appendCookie(cookie)
    }

    @inlinable
    public mutating func setContent(_ content: String) {
        message.setContent(content)
    }

    @inlinable
    public func write<Socket: SocketProtocol & ~Copyable>(to socket: borrowing Socket) throws {
        try message.write(to: socket)
    }
}
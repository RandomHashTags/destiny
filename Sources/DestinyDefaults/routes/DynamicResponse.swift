
import DestinyBlueprint

public struct DynamicResponse: DynamicResponseProtocol {
    public var message:HTTPResponseMessage
    public var parameters:[String]

    public init(
        message: HTTPResponseMessage,
        parameters: [String]
    ) {
        self.message = message
        self.parameters = parameters
    }

    @inlinable
    public func parameter(at index: Int) -> String {
        parameters[index]
    }

    @inlinable
    public mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>) {
        parameters[index] = value.string()
    }

    @inlinable
    public mutating func appendParameter(value: InlineVLArray<UInt8>) {
        parameters.append(value.string())
    }

    @inlinable
    public func yieldParameters(_ yield: (String) -> Void) {
        for parameter in parameters {
            yield(parameter)
        }
    }
}

extension DynamicResponse {
    @inlinable
    public mutating func setHTTPVersion(_ version: HTTPVersion) {
        message.version = version
    }

    @inlinable
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        message.setStatusCode(code)
    }

    @inlinable
    public mutating func setHeader(key: String, value: String) {
        message.setHeader(key: key, value: value)
    }

    @inlinable
    public mutating func appendCookie(_ cookie: some HTTPCookieProtocol) {
        message.appendCookie(cookie)
    }

    @inlinable
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        message.setBody(body)
    }

    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try await message.write(to: socket)
    }
}
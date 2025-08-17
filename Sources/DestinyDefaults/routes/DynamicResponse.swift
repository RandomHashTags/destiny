
import DestinyBlueprint
import VariableLengthArray

/// Default Dynamic Response implementation that builds an HTTP Message for dynamic requests.
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
    public mutating func setParameter(at index: Int, value: consuming VLArray<UInt8>) {
        parameters[index] = value.string()
    }

    @inlinable
    public mutating func appendParameter(value: consuming VLArray<UInt8>) {
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
    public func write(
        to socket: Int32
    ) throws(SocketError) {
        try message.write(to: socket)
    }
}
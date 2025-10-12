
import DestinyBlueprint
import VariableLengthArray

/// Default Dynamic Response implementation that builds an HTTP Message for dynamic requests.
public struct DynamicResponse: Sendable {
    public var message:HTTPResponseMessage
    public var parameters:[String]

    public init(
        message: HTTPResponseMessage,
        parameters: [String]
    ) {
        self.message = message
        self.parameters = parameters
    }

    #if Inlinable
    @inlinable
    #endif
    public func parameter(at index: Int) -> String {
        parameters[index]
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setParameter(at index: Int, value: consuming VLArray<UInt8>) {
        parameters[index] = value.unsafeString()
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func appendParameter(value: consuming VLArray<UInt8>) {
        parameters.append(value.unsafeString())
    }

    #if Inlinable
    @inlinable
    #endif
    public func yieldParameters(_ yield: (String) -> Void) {
        for parameter in parameters {
            yield(parameter)
        }
    }
}

extension DynamicResponse {
    #if Inlinable
    @inlinable
    #endif
    public mutating func setHTTPVersion(_ version: HTTPVersion) {
        message.version = version
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        message.setStatusCode(code)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setHeader(key: String, value: String) {
        message.setHeader(key: key, value: value)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError) {
        try message.appendCookie(cookie)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        message.setBody(body)
    }

    #if Inlinable
    @inlinable
    #endif
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        try message.write(to: socket)
    }
}

// MARK: Conformances
extension DynamicResponse: DynamicResponseProtocol {}
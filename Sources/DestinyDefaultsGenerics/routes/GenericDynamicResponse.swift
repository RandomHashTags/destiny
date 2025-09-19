
import DestinyBlueprint
import DestinyDefaults
import VariableLengthArray

/// Default Dynamic Response implementation that builds an HTTP Message for dynamic requests.
public struct GenericDynamicResponse<
        Message: GenericHTTPMessageProtocol
    >: DynamicResponseProtocol {
    public var message:Message
    public var parameters:[String]

    public init(
        message: Message,
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

extension GenericDynamicResponse {
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
    public mutating func appendCookie(_ cookie: some HTTPCookieProtocol) throws(HTTPCookieError) {
        try message.appendCookie(Message.Cookie.init(copying: cookie))
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        guard let body = body as? Message.Body else { return }
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
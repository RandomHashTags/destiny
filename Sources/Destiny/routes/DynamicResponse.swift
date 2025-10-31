
import VariableLengthArray

#if hasFeature(Embedded) || EMBEDDED

/// Default Dynamic Response implementation that builds an HTTP Message for dynamic requests.
public struct DynamicResponse<
        Body: ResponseBodyProtocol
    >: Sendable {
    public var message:HTTPResponseMessage<Body>
    public var parameters:[String]

    public init(
        message: HTTPResponseMessage<Body>,
        parameters: [String]
    ) {
        self.message = message
        self.parameters = parameters
    }

    public mutating func setBody(_ body: Body) {
        message.setBody(body)
    }

    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        message.setBody(body)
    }
}

#else

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

    public mutating func setBody(_ body: some ResponseBodyProtocol) {
        message.setBody(body)
    }
}
#endif

// MARK: Logic
extension DynamicResponse {
    public func parameter(at index: Int) -> String {
        parameters[index]
    }

    public mutating func setParameter(at index: Int, value: consuming VLArray<UInt8>) {
        parameters[index] = value.unsafeString()
    }

    public mutating func appendParameter(value: consuming VLArray<UInt8>) {
        parameters.append(value.unsafeString())
    }

    public func yieldParameters(_ yield: (String) -> Void) {
        for parameter in parameters {
            yield(parameter)
        }
    }

    public mutating func setHTTPVersion(_ version: HTTPVersion) {
        message.version = version
    }

    public mutating func setStatusCode(_ code: HTTPResponseStatus.Code) {
        message.setStatusCode(code)
    }

    public mutating func setHeader(key: String, value: String) {
        message.setHeader(key: key, value: value)
    }

    #if HTTPCookie
    public mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError) {
        try message.appendCookie(cookie)
    }
    #endif

    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        try message.write(to: socket)
    }
}

// MARK: Conformances
extension DynamicResponse: DynamicResponseProtocol {}
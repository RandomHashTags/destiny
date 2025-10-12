
#if GenericHTTPMessage

/// Core protocol that builds a complete HTTP Message.
public protocol GenericHTTPMessageProtocol: AbstractHTTPMessageProtocol, ~Copyable {
    associatedtype Body:ResponseBodyProtocol

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    mutating func setBody(_ body: Body)

    mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError)
}

#endif

/// Core protocol that builds a complete HTTP Message.
public protocol HTTPMessageProtocol: AbstractHTTPMessageProtocol, ~Copyable {
    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    mutating func setBody(_ body: some ResponseBodyProtocol)

    mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError)
}

/// Core HTTP Message protocol that builds a complete HTTP Message.
public protocol HTTPMessageProtocol: HTTPSocketWritable, ~Copyable {

    var version: HTTPVersion { get set }

    /// Set the message's status code.
    /// 
    /// - Parameters:
    ///   - code: The new status code to set.
    mutating func setStatusCode(_ code: HTTPResponseStatus.Code)

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: The new body to set.
    mutating func setBody(_ body: some ResponseBodyProtocol)

    /// Set a header to the given value.
    /// 
    /// - Parameters:
    ///   - key: The header you want to modify.
    ///   - value: The new header value to set.
    mutating func setHeader(key: String, value: String)

    mutating func appendCookie(_ cookie: some HTTPCookieProtocol)

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the body.
    /// - Returns: A string representing an HTTP Message with the given values.
    func string(
        escapeLineBreak: Bool
    ) throws(HTTPMessageError) -> String
}
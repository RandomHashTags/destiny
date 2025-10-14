
/// Core protocol that builds a complete HTTP Message.
public protocol AbstractHTTPMessageProtocol: HTTPSocketWritable, ~Copyable {

    /// Associated HTTP Version of this message.
    var version: HTTPVersion { get set }

    /// - Returns: Current status code this message.
    func statusCode() -> HTTPResponseStatus.Code

    /// Set the message's status code.
    /// 
    /// - Parameters:
    ///   - code: New status code to set.
    mutating func setStatusCode(_ code: HTTPResponseStatus.Code)

    /// Set a header to the given value.
    /// 
    /// - Parameters:
    ///   - key: Header you want to modify.
    ///   - value: New header value to set.
    mutating func setHeader(key: String, value: String)

    /// - Throws: `HTTPCookieError`
    mutating func appendCookie(_ cookie: HTTPCookie) throws(HTTPCookieError)

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the body.
    /// 
    /// - Returns: A string representing an HTTP Message with the given values.
    /// - Throws: `HTTPMessageError`
    func string(
        escapeLineBreak: Bool
    ) throws(HTTPMessageError) -> String
}
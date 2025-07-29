
public protocol HTTPMessageProtocol: Sendable, ~Copyable {

    var version: HTTPVersion { get set }

    /// Set the message's status.
    /// 
    /// Default behavior of this function calls `setStatusCode(code:)` with the given type's code.
    /// 
    /// - Parameters:
    ///   - status: A concrete type conforming to `HTTPResponseStatus.StorageProtocol`.
    mutating func setStatus(_ status: some HTTPResponseStatus.StorageProtocol)

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
    func string(escapeLineBreak: Bool) throws -> String

    /// Writes a message to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) throws
}

extension HTTPMessageProtocol {
    @inlinable
    public mutating func setStatus(_ status: some HTTPResponseStatus.StorageProtocol) {
        setStatusCode(status.code)
    }
}

public protocol HTTPMessageProtocol: CustomDebugStringConvertible, Sendable {

    @inlinable
    var version: HTTPVersion { get set }

    @inlinable
    var status: HTTPResponseStatus.Code { get set }

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: The new body to set.
    @inlinable
    mutating func setBody(_ body: String)

    /// Set a header to the given value.
    /// 
    /// - Parameters:
    ///   - key: The header you want to modify.
    ///   - value: The new header value to set.
    @inlinable
    mutating func setHeader(key: String, value: String)

    @inlinable
    mutating func appendCookie<T: HTTPCookieProtocol>(_ cookie: T)

    /// - Parameters:
    ///   - escapeLineBreak: Whether or not to use `\\r\\n` or `\r\n` in the result.
    /// - Returns: A string representing an HTTP Message with the given values.
    @inlinable
    func string(escapeLineBreak: Bool) throws -> String

    /// Writes a message to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    @inlinable
    func write<Socket: SocketProtocol & ~Copyable>(to socket: borrowing Socket) throws
}
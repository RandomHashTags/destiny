
/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol: Sendable, CustomDebugStringConvertible {
    /// Timestamps when request events happen.
    var timestamps: DynamicRequestTimestamps { get set }

    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The parameter located at the given path component index.
    @inlinable
    func parameter(at index: Int) -> String

    @inlinable
    mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>)

    @inlinable
    mutating func appendParameter(value: InlineVLArray<UInt8>)

    @inlinable
    func yieldParameters(_ yield: (String) -> Void)

    /// Set the response's HTTP Version.
    /// 
    /// - Parameters:
    ///   - version: The new HTTP Version to set.
    @inlinable
    mutating func setHTTPVersion(_ version: HTTPVersion)

    /// Set the response's status.
    /// 
    /// Default behavior of this function calls `setStatusCode(code:)` with the given type's code.
    /// 
    /// - Parameters:
    ///   - status: A concrete type conforming to `HTTPResponseStatus.StorageProtocol`.
    @inlinable
    mutating func setStatus<T: HTTPResponseStatus.StorageProtocol>(_ status: T)

    /// Set the response's status code.
    /// 
    /// - Parameters:
    ///   - code: The new status code to set.
    @inlinable
    mutating func setStatusCode(_ code: HTTPResponseStatus.Code)

    /// Set a response header to the given value.
    /// 
    /// - Parameters:
    ///   - key: The header you want to modify.
    ///   - value: The new header value to set.
    @inlinable
    mutating func setHeader(key: String, value: String)

    @inlinable
    mutating func appendCookie<Cookie: HTTPCookieProtocol>(_ cookie: Cookie)

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: The new body to set.
    @inlinable
    mutating func setBody<T: ResponseBodyProtocol>(_ body: T)

    /// Writes an HTTP Message to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    @inlinable
    func write<Socket: HTTPSocketProtocol & ~Copyable>(to socket: borrowing Socket) throws
}

extension DynamicResponseProtocol {
    @inlinable
    public mutating func setStatus<T: HTTPResponseStatus.StorageProtocol>(_ status: T) {
        setStatusCode(status.code)
    }
}
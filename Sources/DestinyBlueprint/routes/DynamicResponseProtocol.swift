
/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol: Sendable, CustomDebugStringConvertible {
    /// Timestamps when request events happen.
    var timestamps: DynamicRequestTimestamps { get set }

    @inlinable
    func parameter(at index: Int) -> String

    @inlinable
    mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>)

    @inlinable
    mutating func setHTTPVersion(_ version: HTTPVersion)

    @inlinable
    mutating func setStatus(_ code: HTTPResponseStatus.Code)

    @inlinable
    mutating func setHeader(key: String, value: String)

    @inlinable
    mutating func appendCookie<Cookie: HTTPCookieProtocol>(_ cookie: Cookie)

    @inlinable
    mutating func setResult(_ result: String)

    @inlinable
    func write<Socket: SocketProtocol & ~Copyable>(to socket: borrowing Socket) throws
}
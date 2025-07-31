
/// Core Dynamic Response protocol that builds a HTTP Message to dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol: HTTPSocketWritable, ~Copyable {
    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The parameter located at the given path component index.
    func parameter(at index: Int) -> String

    mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>)

    mutating func appendParameter(value: InlineVLArray<UInt8>)

    func yieldParameters(_ yield: (String) -> Void)

    /// Set the response's HTTP Version.
    /// 
    /// - Parameters:
    ///   - version: The new HTTP Version to set.
    mutating func setHTTPVersion(_ version: HTTPVersion)

    /// Set the response's status code.
    /// 
    /// - Parameters:
    ///   - code: The new status code to set.
    mutating func setStatusCode(_ code: HTTPResponseStatus.Code)

    /// Set a response header to the given value.
    /// 
    /// - Parameters:
    ///   - key: The header you want to modify.
    ///   - value: The new header value to set.
    mutating func setHeader(key: String, value: String)

    mutating func appendCookie(_ cookie: some HTTPCookieProtocol)

    /// Set the body of the message.
    /// 
    /// - Parameters:
    ///   - body: The new body to set.
    mutating func setBody(_ body: some ResponseBodyProtocol)
}
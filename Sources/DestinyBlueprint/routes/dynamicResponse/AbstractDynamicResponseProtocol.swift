
import VariableLengthArray

/// Core protocol that builds a HTTP Message for dynamic routes before sending it to the client.
public protocol AbstractDynamicResponseProtocol: HTTPSocketWritable, ~Copyable {
    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The parameter located at the given path component index.
    func parameter(at index: Int) -> String

    mutating func setParameter(
        at index: Int,
        value: consuming VLArray<UInt8>
    )

    mutating func appendParameter(value: consuming VLArray<UInt8>)

    func yieldParameters(_ yield: (String) -> Void)

    /// Sets the HTTP Version of the message.
    /// 
    /// - Parameters:
    ///   - version: New HTTP Version to set.
    mutating func setHTTPVersion(_ version: HTTPVersion)

    /// Sets the status code of the message.
    /// 
    /// - Parameters:
    ///   - code: New status code to set.
    mutating func setStatusCode(_ code: HTTPResponseStatus.Code)

    /// Sets a header to the given value.
    /// 
    /// - Parameters:
    ///   - key: Header you want to modify.
    ///   - value: New header value to set.
    /// 
    /// - Warning: `key` is case-sensitive!
    mutating func setHeader(key: String, value: String)
}
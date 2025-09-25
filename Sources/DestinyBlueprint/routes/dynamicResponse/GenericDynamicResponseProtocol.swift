
#if GenericDynamicResponse

/// Core protocol that builds a HTTP Message for dynamic routes before sending it to the client.
public protocol GenericDynamicResponseProtocol: AbstractDynamicResponseProtocol, ~Copyable {
    associatedtype Body:ResponseBodyProtocol
    associatedtype Cookie:HTTPCookieProtocol

    mutating func appendCookie(_ cookie: Cookie) throws(HTTPCookieError)

    /// Sets the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    mutating func setBody(_ body: Body)
}

#endif
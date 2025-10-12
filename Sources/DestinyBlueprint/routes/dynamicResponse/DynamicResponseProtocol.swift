
/// Core protocol that builds a HTTP Message for dynamic routes before sending it to the client.
public protocol DynamicResponseProtocol: AbstractDynamicResponseProtocol, ~Copyable {
    /// Sets the body of the message.
    /// 
    /// - Parameters:
    ///   - body: New body to set.
    mutating func setBody(_ body: some ResponseBodyProtocol)
}
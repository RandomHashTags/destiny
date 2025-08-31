
/// Core immutable Responder Storage protocol that stores responders.
public protocol ResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - startLine: The socket's requested endpoint.
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}
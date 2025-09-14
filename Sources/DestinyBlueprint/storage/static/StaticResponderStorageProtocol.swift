
/// Core protocol that stores static responders for static routes.
public protocol StaticResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this storage belongs to.
    ///   - socket: Socket to write to.
    ///   - startLine: Socket's requested endpoint.
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}
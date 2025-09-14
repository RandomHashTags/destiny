
/// Core protocol that stores dynamic responders for dynamic routes.
public protocol DynamicResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this storage belongs to.
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}

/// Core immutable Route Group Storage protocol that stores responders for routes within this route group.
public protocol RouteGroupStorageProtocol: Sendable, ~Copyable {
    /// Responds to a socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}
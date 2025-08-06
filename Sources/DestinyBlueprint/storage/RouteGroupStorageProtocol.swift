
public protocol RouteGroupStorageProtocol: Sendable, ~Copyable {
    /// Responds to a socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool
}
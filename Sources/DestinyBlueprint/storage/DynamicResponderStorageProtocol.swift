
public protocol DynamicResponderStorageProtocol: CustomDebugStringConvertible, Sendable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - received: The instant the socket was accepted.
    ///   - loaded: The instant the socket loaded its default values.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a response was sent.
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool
}
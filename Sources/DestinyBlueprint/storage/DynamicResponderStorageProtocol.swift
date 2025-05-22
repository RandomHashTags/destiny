
public protocol DynamicResponderStorageProtocol: CustomDebugStringConvertible, Sendable {
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
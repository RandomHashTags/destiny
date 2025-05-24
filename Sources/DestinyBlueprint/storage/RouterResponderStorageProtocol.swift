
public protocol RouterResponderStorageProtocol: Sendable {
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

    /// Try to write a response to a socket, only checking static storage.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - startLine: The socket's target endpoint.
    /// - Returns: Whether or not a response was sent.
    @inlinable
    func respondStatically<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool

    /// Try to write a response to a socket, only checking dynamic storage.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - received: The instant the socket was accepted.
    ///   - loaded: The instant the socket loaded its default values.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a response was sent.
    @inlinable
    func respondDynamically<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
    ) async throws -> Bool
}
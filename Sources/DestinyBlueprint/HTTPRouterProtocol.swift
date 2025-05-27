
import Logging

/// Core HTTPRouter protocol that handles middleware, routes and router groups.
public protocol HTTPRouterProtocol: Sendable, ~Copyable {
    @inlinable mutating func loadDynamicMiddleware()

    /// Process an accepted file descriptor.
    /// 
    /// - Parameters:
    ///   - client: The accepted file descriptor.
    ///   - received: The instant the socket was accepted.
    ///   - socket: The socket to write to.
    ///   - logger: The `Logger` that logs relevant details.
    @inlinable
    func process<Socket: HTTPSocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws

    /// Writes a static responder to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - responder: The static route responder that will write to the socket.
    @inlinable
    func respondStatically<Socket: HTTPSocketProtocol & ~Copyable, Responder: StaticRouteResponderProtocol>(
        socket: borrowing Socket,
        responder: Responder
    ) async throws

    /// Writes a dynamic responder to the socket.
    /// 
    /// - Parameters:
    ///   - received: The instant the socket was accepted.
    ///   - loaded: The instant the socket loaded its default values.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - responder: The dynamic route responder that will write to the socket.
    @inlinable
    func respondDynamically<Socket: HTTPSocketProtocol & ~Copyable, Responder: DynamicRouteResponderProtocol>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
        responder: Responder
    ) async throws
}
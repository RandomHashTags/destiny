
import Logging

/// Core Router protocol that handles middleware, routes and router groups.
public protocol RouterProtocol: Sendable, ~Copyable {
    @inlinable mutating func loadDynamicMiddleware()

    /// Process an accepted file descriptor.
    @inlinable
    func process<Socket: SocketProtocol & ~Copyable>(
        client: Int32,
        received: ContinuousClock.Instant,
        socket: borrowing Socket,
        logger: Logger
    ) async throws

    @inlinable
    func respondStatically<Socket: SocketProtocol & ~Copyable, Responder: StaticRouteResponderProtocol>(
        socket: borrowing Socket,
        responder: Responder
    ) async throws

    @inlinable
    func respondDynamically<Socket: SocketProtocol & ~Copyable, Responder: DynamicRouteResponderProtocol>(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
        responder: Responder
    ) async throws
}
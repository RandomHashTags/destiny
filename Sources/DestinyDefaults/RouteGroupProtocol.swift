
import DestinyBlueprint

/// Core Route Group protocol that handles routes grouped by a single endpoint.
public protocol RouteGroupProtocol: Sendable, ~Copyable {

    /// - Returns: Whether or not this router group responded to the request.
    @inlinable
    func respond<Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool
}
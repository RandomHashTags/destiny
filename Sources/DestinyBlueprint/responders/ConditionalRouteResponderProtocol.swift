
/// Core Conditional Route Responder protocol that selects a route responder based on a request.
public protocol ConditionalRouteResponderProtocol: CustomDebugStringConvertible, RouteResponderProtocol {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this route belongs to.
    ///   - received: The instant the socket was accepted.
    ///   - loaded: The instant the socket loaded its default values.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a route responder responded to the request.
    @inlinable
    func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool
}
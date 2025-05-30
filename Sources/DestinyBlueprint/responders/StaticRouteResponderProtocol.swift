
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable
    func respond<Socket: HTTPSocketProtocol & ~Copyable>(to socket: borrowing Socket) async throws
}
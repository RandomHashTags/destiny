
/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol: RouteResponderProtocol {

    /// Yields the path of the route.
    @inlinable
    func forEachPathComponent(_ yield: (PathComponent) -> Void)

    /// - Returns: The `PathComponent` located at the given index.
    func pathComponent(at index: Int) -> PathComponent

    /// The number of path components this route contains.
    var pathComponentsCount: Int { get }

    /// Yields the index where parameters are location in the path.
    @inlinable
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse: any DynamicResponseProtocol { get }

    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - response: The response to send to the socket.
    @inlinable
    func respond<Socket: HTTPSocketProtocol & ~Copyable>(
        to socket: borrowing Socket,
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws
}
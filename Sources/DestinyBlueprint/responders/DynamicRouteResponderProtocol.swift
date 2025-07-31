
/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol: RouteResponderProtocol, CustomDebugStringConvertible {
    /// - Returns: The `PathComponent` located at the given index.
    func pathComponent(at index: Int) -> PathComponent

    /// The number of path components this route contains.
    var pathComponentsCount: Int { get }

    /// Yields the index where parameters are location in the path.
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    var defaultResponse: any DynamicResponseProtocol { get }

    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - response: The response to send to the socket.
    func respond(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) async throws
}
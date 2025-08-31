
/// Core Dynamic Route Responder protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol: RouteResponderProtocol, ~Copyable {
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol

    /// - Returns: The `PathComponent` located at the given index.
    func pathComponent(at index: Int) -> PathComponent

    /// The number of path components this route contains.
    var pathComponentsCount: Int { get }

    /// Yields the indexes where a parameter is located in the path.
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    func defaultResponse() -> ConcreteDynamicResponse

    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this responder is stored in.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - response: The http message to send to the socket.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)
}

extension DynamicRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try router.respond(socket: socket, request: &request, responder: self, completionHandler: completionHandler)
    }
}
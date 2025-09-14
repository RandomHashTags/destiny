
/// Core protocol that handles requests to dynamic routes.
public protocol DynamicRouteResponderProtocol: RouteResponderProtocol, ~Copyable {
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol

    /// - Returns: The `PathComponent` located at the given index.
    /// - Warning: **Does no bounds checking**.
    func pathComponent(at index: Int) -> PathComponent

    /// Number of path components this route contains.
    var pathComponentsCount: Int { get }

    /// Yields the indexes where a parameter is located in the path.
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    func defaultResponse() -> ConcreteDynamicResponse

    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - response: HTTP Message to send to the socket.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)
}

// MARK: Defaults
extension DynamicRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try router.respond(socket: socket, request: &request, responder: self, completionHandler: completionHandler)
    }
}


/// Core protocol that handles middleware, routes and route groups.
public protocol HTTPRouterProtocol: AbstractHTTPRouterProtocol, ~Copyable {
    /// Writes a static response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - responder: Route responder that will write to the socket.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        request: inout HTTPRequest,
        responder: some RouteResponderProtocol
    ) throws(ResponderError)

    /// Writes a dynamic response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - responder: Dynamic route responder that will write to the socket.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        request: inout HTTPRequest,
        responder: some DynamicRouteResponderProtocol
    ) throws(ResponderError)

    /// Writes a response, usually a 404, to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    func respondWithNotFound(
        provider: some SocketProvider,
        request: inout HTTPRequest
    ) throws(ResponderError) -> Bool

    /// Writes an error response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - error: The encountered error.
    ///   - request: Socket's request.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithError(
        provider: some SocketProvider,
        request: inout HTTPRequest,
        error: some Error
    ) -> Bool
}


/// Core protocol that handles middleware, routes and route groups.
public protocol HTTPRouterProtocol: AbstractHTTPRouterProtocol, ~Copyable {
    /// Writes a static response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - responder: Route responder that will write to the socket.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        responder: some RouteResponderProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)

    /// Writes a dynamic response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - responder: Dynamic route responder that will write to the socket.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        responder: some DynamicRouteResponderProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)

    /// Writes a response, usually a 404, to the socket.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    func respondWithNotFound(
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool

    /// Writes an error response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - error: The encountered error.
    ///   - request: Socket's request.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithError(
        socket: some FileDescriptor,
        error: some Error,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) -> Bool
}
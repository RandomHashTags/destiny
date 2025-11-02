
#if NonCopyable

/// Core protocol that handles middleware, routes and route groups.
public protocol NonCopyableHTTPRouterProtocol: AbstractHTTPRouterProtocol, ~Copyable {
    /// Writes a static response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - responder: Static route responder that will write to the socket
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        request: inout HTTPRequest,
        responder: borrowing some NonCopyableRouteResponderProtocol & ~Copyable
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
        responder: borrowing some NonCopyableDynamicRouteResponderProtocol & ~Copyable
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
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithError(
        provider: some SocketProvider,
        request: inout HTTPRequest,
        error: some Error
    ) -> Bool
}

#endif
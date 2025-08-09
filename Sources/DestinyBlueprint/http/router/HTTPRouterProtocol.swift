
import Logging

/// Core HTTP Router protocol that handles middleware, routes and router groups.
public protocol HTTPRouterProtocol: Sendable, ~Copyable {
    /// Load logic before this router is ready to handle sockets.
    func load() throws(RouterError)

    /// Handle logic for a given socket.
    /// 
    /// - Parameters:
    ///   - client: File descriptor assigned to the socket.
    ///   - socket: The socket.
    ///   - logger: Logger of the socket acceptor that called this function.
    func handle(
        client: Int32,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        logger: Logger
    )

    /// Writes a static response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - responder: The static route responder that will write to the socket.
    func respondStatically(
        socket: Int32,
        responder: some StaticRouteResponderProtocol
    ) throws(ResponderError)

    /// Writes a dynamic response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - responder: The dynamic route responder that will write to the socket.
    func respondDynamically(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) throws(ResponderError)

    /// Writes a response, usually a 404, to the socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithNotFound(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) throws(ResponderError) -> Bool

    /// Writes an error response to the socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithError(
        socket: Int32,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) -> Bool
}
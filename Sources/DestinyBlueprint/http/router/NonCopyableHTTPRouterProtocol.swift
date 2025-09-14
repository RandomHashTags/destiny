
import Logging

/// Core protocol that handles middleware, routes and route groups.
public protocol NonCopyableHTTPRouterProtocol: Sendable, ~Copyable {
    /// Load logic before this router is ready to handle sockets.
    func load() throws(RouterError)

    /// Handle logic for a given socket.
    /// 
    /// - Parameters:
    ///   - client: File descriptor assigned to the socket.
    ///   - socket: The socket.
    ///   - logger: Logger of the socket acceptor that called this function.
    func handle(
        client: some FileDescriptor,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    )

    /// Writes a static response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - responder: Static route responder that will write to the socket.
    func respond(
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: borrowing some NonCopyableStaticRouteResponderProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)

    /// Writes a dynamic response to the socket.
    /// 
    /// - Parameters:
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - responder: Dynamic route responder that will write to the socket.
    func respond(
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: borrowing some NonCopyableDynamicRouteResponderProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)

    /// Writes a response, usually a 404, to the socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithNotFound(
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool

    /// Writes an error response to the socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respondWithError(
        socket: some FileDescriptor,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) -> Bool
}
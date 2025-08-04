
import Logging

/// Core HTTPRouter protocol that handles middleware, routes and router groups.
public protocol HTTPRouterProtocol: AnyObject, Sendable {
    func loadDynamicMiddleware()

    func handle(
        client: Int32,
        socket: consuming some HTTPSocketProtocol & ~Copyable,
        logger: Logger
    )

    /// Writes a static responder to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - responder: The static route responder that will write to the socket.
    func respondStatically(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        responder: some StaticRouteResponderProtocol
    ) async throws(ResponderError)

    /// Writes a dynamic responder to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - responder: The dynamic route responder that will write to the socket.
    func respondDynamically(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) async throws(ResponderError)
}
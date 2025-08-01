
import Logging

/// Core HTTPRouter protocol that handles middleware, routes and router groups.
public protocol HTTPRouterProtocol: Sendable, ~Copyable {
    mutating func loadDynamicMiddleware()

    /// Process an accepted file descriptor.
    /// 
    /// - Parameters:
    ///   - client: The accepted file descriptor.
    ///   - socket: The socket to write to.
    ///   - logger: The `Logger` that logs relevant details.
    func process(
        client: Int32,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        logger: Logger
    ) async throws

    /// Writes a static responder to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket to write to.
    ///   - responder: The static route responder that will write to the socket.
    func respondStatically(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        responder: some StaticRouteResponderProtocol
    ) async throws

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
    ) async throws
}
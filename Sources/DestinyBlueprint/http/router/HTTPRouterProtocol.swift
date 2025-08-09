
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

    /// Handle dynamic middleware for a given request and dynamic response.
    func handleDynamicMiddleware(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) async throws(ResponderError)

    /// Responds to a socket.
    /// 
    /// - Parameters:
    ///   - socket: File descriptor assigned to the socket.
    ///   - request: A loaded request for the socket.
    ///   - logger: Logger of the socket acceptor that called this function.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respond(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) async throws(ResponderError) -> Bool

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
    ) async throws(ResponderError)
}

// MARK: Defaults
extension HTTPRouterProtocol {
    @inlinable
    public func respondStatically(
        socket: Int32,
        responder: borrowing some StaticRouteResponderProtocol
    ) throws(ResponderError) {
        do throws(SocketError) {
            try responder.write(to: socket)
        } catch {
            throw .socketError(error)
        }
    }

    @inlinable
    public func defaultDynamicResponse(
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) async throws(ResponderError) -> some DynamicResponseProtocol {
        var response = responder.defaultResponse()
        var index = 0
        let maximumParameters = responder.pathComponentsCount
        responder.forEachPathComponentParameterIndex { parameterIndex in
            request.path(at: parameterIndex).inlineVLArray {
                response.setParameter(at: index, value: $0)
            }
            if responder.pathComponent(at: parameterIndex) == .catchall {
                var i = parameterIndex+1
                request.forEachPath(offset: i) { path in
                    path.inlineVLArray {
                        if i < maximumParameters {
                            response.setParameter(at: i, value: $0)
                        } else {
                            response.appendParameter(value: $0)
                        }
                    }
                    i += 1
                }
            }
            index += 1
        }
        try await handleDynamicMiddleware(for: &request, with: &response)
        return response
    }

    @inlinable
    public func respondDynamically(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) async throws(ResponderError) {
        var response = try await defaultDynamicResponse(request: &request, responder: responder)
        try await responder.respond(to: socket, request: &request, response: &response)
    }
}
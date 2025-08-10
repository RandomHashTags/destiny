
import DestinyBlueprint
import Logging

public protocol DestinyHTTPRouterProtocol: HTTPRouterProtocol, ~Copyable {
    /// Handle dynamic middleware for a given request and dynamic response.
    func handleDynamicMiddleware(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError)

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
    ) throws(ResponderError) -> Bool
}

// MARK: Defaults
extension DestinyHTTPRouterProtocol {
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
    ) throws(ResponderError) -> some DynamicResponseProtocol {
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
        return response
    }

    @inlinable
    public func respondDynamically(
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol
    ) throws(ResponderError) {
        var response = try defaultDynamicResponse(request: &request, responder: responder)
        do throws(MiddlewareError) {
            try handleDynamicMiddleware(for: &request, with: &response)
        } catch {
            throw .middlewareError(error)
        }
        try responder.respond(router: self, socket: socket, request: &request, response: &response)
    }
}

import DestinyBlueprint
import Logging
import VariableLengthArray

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
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}

// MARK: Defaults
extension DestinyHTTPRouterProtocol {
    @inlinable
    public func respond(
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: borrowing some StaticRouteResponderProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        do throws(SocketError) {
            try responder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)
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
        var err:SocketError? = nil
        responder.forEachPathComponentParameterIndex { parameterIndex in
            let pathAtIndex:String
            do throws(SocketError) {
                pathAtIndex = try request.path(at: parameterIndex)
            } catch {
                err = error
                return
            }
            pathAtIndex.inlineVLArray {
                response.setParameter(at: index, value: $0)
            }
            if responder.pathComponent(at: parameterIndex) == .catchall {
                do throws(SocketError) {
                    var i = parameterIndex+1
                    try request.forEachPath(offset: i) { path in
                        path.inlineVLArray {
                            if i < maximumParameters {
                                response.setParameter(at: i, value: $0)
                            } else {
                                response.appendParameter(value: $0)
                            }
                        }
                        i += 1
                    }
                } catch {
                    err = error
                    return
                }
                
            }
            index += 1
        }
        if let err {
            throw .socketError(err)
        }
        return response
    }

    @inlinable
    public func respond(
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        responder: some DynamicRouteResponderProtocol,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var response = try defaultDynamicResponse(request: &request, responder: responder)
        do throws(MiddlewareError) {
            try handleDynamicMiddleware(for: &request, with: &response)
        } catch {
            throw .middlewareError(error)
        }
        try responder.respond(router: self, socket: socket, request: &request, response: &response, completionHandler: completionHandler)
    }
}
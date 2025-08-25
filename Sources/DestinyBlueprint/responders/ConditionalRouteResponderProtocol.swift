
/// Core Conditional Route Responder protocol that selects a route responder based on a request.
public protocol ConditionalRouteResponderProtocol: CustomDebugStringConvertible, RouteResponderProtocol {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this route belongs to.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a route responder responded to the request.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) throws(ResponderError) -> Bool
}
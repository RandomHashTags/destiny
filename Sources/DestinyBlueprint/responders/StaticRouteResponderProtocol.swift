
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, ~Copyable {
    /// Synchronously writes data to the socket.
    /// 
    /// - Parameters:
    ///   - router: The router.
    ///   - socket: The socket.
    ///   - request: The request.
    ///   - completionHandler: Call when you're done successfully responding.
    func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(SocketError)
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(SocketError) {
        try self.write(to: socket)
        completionHandler()
    }
}

extension StaticString: StaticRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(SocketError) {
        try self.write(to: socket)
        completionHandler()
    }
}

extension [UInt8]: StaticRouteResponderProtocol {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(SocketError) {
        try self.write(to: socket)
        completionHandler()
    }
}
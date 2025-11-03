
/// Core protocol that writes its response to requests.
public protocol RouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - router: Router this responder is stored in.
    ///   - request: Socket's request.
    /// 
    /// - Throws: `DestinyError`
    func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}
#endif

extension StaticString: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}

extension [UInt8]: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}
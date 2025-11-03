
#if NonCopyable

/// Core protocol that writes its response to requests.
public protocol NonCopyableRouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - router: Router this responder is stored in.
    ///   - request: Socket's request.
    /// 
    /// - Throws: `DestinyError`
    func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}
#endif

extension StaticString: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}

extension [UInt8]: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(DestinyError) {
        try self.write(to: request.fileDescriptor)
        request.fileDescriptor.flush(provider: provider)
    }
}

#endif
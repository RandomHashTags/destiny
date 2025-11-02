
#if MutableRouter

public final class RouteGroupStorage: @unchecked Sendable { // TODO: avoid existentials / support embedded
    @usableFromInline
    var groups:[any ResponderStorageProtocol]

    public init(_ groups: [any ResponderStorageProtocol] = []) {
        self.groups = groups
    }
}

// MARK: Respond
extension RouteGroupStorage {
    /// Responds to a socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(ResponderError) -> Bool {
        for group in groups {
            if try group.respond(provider: provider, router: router, request: &request) {
                return true
            }
        }
        return false
    }
}

#endif

#if RouteGroup

/// Core protocol that stores route responders for routes within this route group.
public protocol RouteGroupStorageProtocol: Sendable, ~Copyable {
    /// Responds to a socket.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}

#endif
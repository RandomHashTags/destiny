
#if RouteGroup

/// Core protocol that stores route responders for routes within this route group.
public protocol RouteGroupStorageProtocol: Sendable, ~Copyable {
    /// Responds to a socket.
    /// 
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}

#endif

#if NonCopyable

/// Core protocol that stores route responders.
public protocol NonCopyableResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this storage belongs to.
    ///   - socket: Socket to write to.
    ///   - request: Socket's incoming data.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool
}

#endif
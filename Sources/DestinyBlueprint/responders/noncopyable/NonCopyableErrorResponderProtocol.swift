
#if NonCopyable

/// Core protocol that handles errors thrown from requests.
public protocol NonCopyableErrorResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        error: some Error,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    )
}

#endif
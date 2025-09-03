
import Logging

/// Core Error Middleware protocol that handles errors thrown from requests.
public protocol NonCopyableErrorResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger,
        completionHandler: @Sendable @escaping () -> Void
    )
}
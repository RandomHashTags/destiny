
import Logging

/// Core protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger,
        completionHandler: @Sendable @escaping () -> Void
    )
}
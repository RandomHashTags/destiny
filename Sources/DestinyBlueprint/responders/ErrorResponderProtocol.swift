
import Logging

/// Core Error Middleware protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol: RouteResponderProtocol, ~Copyable {
    /// Writes a response to a socket.
    func respond(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    )
}
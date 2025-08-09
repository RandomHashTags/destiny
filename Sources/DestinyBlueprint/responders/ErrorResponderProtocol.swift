
import Logging

/// Core Error Middleware protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol: RouteResponderProtocol, ~Copyable {
    /// Writes a response to a socket.
    func respond(
        socket: Int32,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    )
}
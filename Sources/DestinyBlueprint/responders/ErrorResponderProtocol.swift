
import Logging

/// Core Error Middleware protocol that handles errors thrown from requests.
public protocol ErrorResponderProtocol: RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable
    func respond<Socket: HTTPSocketProtocol & ~Copyable, E: Error>(
        to socket: borrowing Socket,
        with error: E,
        for request: inout any HTTPRequestProtocol,
        logger: Logger
    ) async
}
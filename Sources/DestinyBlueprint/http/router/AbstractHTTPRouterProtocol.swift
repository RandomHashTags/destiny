
#if Logging
import Logging
#endif

public protocol AbstractHTTPRouterProtocol: Sendable, ~Copyable {

    #if Logging
    /// The router's logger.
    var logger: Logger { get }
    #endif

    /// Load logic before this router is ready to handle sockets.
    func load() throws(RouterError)

    /// Handle logic for a given socket.
    /// 
    /// - Parameters:
    ///   - client: File descriptor assigned to the socket.
    ///   - socket: The socket.
    ///   - logger: Logger of the socket acceptor that called this function.
    func handle(
        client: some FileDescriptor,
        socket: consuming some SocketProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    )
}
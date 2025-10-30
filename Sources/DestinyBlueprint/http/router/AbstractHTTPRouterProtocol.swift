
#if Logging
import Logging
#endif

/// A bare-bones protocol all routers conform to.
public protocol AbstractHTTPRouterProtocol: Sendable, ~Copyable {

    #if Logging
    /// The router's logger.
    var logger: Logger { get }
    #endif

    /// Load logic before this router is ready to handle sockets.
    /// 
    /// - Throws: `RouterError`
    func load() throws(RouterError)

    /// Handle logic for a given socket.
    /// 
    /// - Parameters:
    ///   - client: File descriptor assigned to the socket.
    ///   - socket: The socket.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    func handle(
        client: some FileDescriptor,
        socket: consuming some FileDescriptor & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    )
}
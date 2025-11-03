

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
    /// - Throws: `DestinyError`
    func load() throws(DestinyError)

    /// Handle logic for a given socket.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - socket: The socket.
    func handle(
        provider: some SocketProvider,
        socket: consuming some FileDescriptor & ~Copyable
    )
}
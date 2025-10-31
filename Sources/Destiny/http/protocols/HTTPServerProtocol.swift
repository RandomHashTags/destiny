
#if Logging
import Logging
#endif

/// Core protocol that accepts and processes incoming network requests.
public protocol HTTPServerProtocol: DestinyServiceProtocol, ~Copyable {

    #if Logging
    /// Main logger for the server.
    var logger: Logger { get }
    #endif
}
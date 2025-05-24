
import Logging
import ServiceLifecycle

/// Core Server protocol that accepts and processes incoming network requests.
public protocol HTTPServerProtocol: Service {
    /// Main logger for the server.
    var logger: Logger { get }
}

import Logging

/// Core protocol that accepts and processes incoming network requests.
public protocol HTTPServerProtocol: DestinyServiceProtocol, ~Copyable {
    /// Main logger for the server.
    var logger: Logger { get }
}
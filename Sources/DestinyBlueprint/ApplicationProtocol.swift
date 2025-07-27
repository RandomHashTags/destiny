
import Logging

public protocol ApplicationProtocol: DestinyServiceProtocol, ~Copyable {
    
    /// The application's logger.
    var logger: Logger { get }
}
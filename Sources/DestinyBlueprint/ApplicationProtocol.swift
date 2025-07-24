
import Logging

public protocol ApplicationProtocol: DestinyServiceProtocol {
    
    /// The application's logger.
    var logger: Logger { get }
}
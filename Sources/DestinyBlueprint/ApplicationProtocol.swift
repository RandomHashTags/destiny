
import Logging

public protocol ApplicationProtocol: DestinyServiceProtocol {
    
    /// The application's logger.
    var logger: Logger { get }

    /// Shut down the application.
    func shutdown() async throws
}
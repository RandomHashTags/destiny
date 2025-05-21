
import Logging
import ServiceLifecycle

public protocol ApplicationProtocol: Service {
    
    /// The application's logger.
    var logger: Logger { get }

    /// Shut down the application.
    func shutdown() async throws
}
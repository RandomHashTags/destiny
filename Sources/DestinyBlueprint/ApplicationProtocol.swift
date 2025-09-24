
#if Logging
import Logging
#endif

public protocol ApplicationProtocol: DestinyServiceProtocol, ~Copyable {

    #if Logging
    /// The application's logger.
    var logger: Logger { get }
    #endif
}
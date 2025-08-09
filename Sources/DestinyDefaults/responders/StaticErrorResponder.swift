
import DestinyBlueprint
import Logging

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct StaticErrorResponder: ErrorResponderProtocol {
    public let logic:@Sendable (_ error: any Error) -> any StaticRouteResponderProtocol

    public init(_ logic: @Sendable @escaping (_ error: any Error) -> any StaticRouteResponderProtocol) {
        self.logic = logic
    }

    @inlinable
    public func respond(
        socket: Int32,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) {
        #if DEBUG
        logger.warning("\(error)")
        #endif
        do throws(SocketError) {
            try logic(error).write(to: socket)
        } catch {
            logger.warning("[StaticErrorResponder] Encountered error trying to write response: \(error)")
        }
        socket.socketClose()
    }
}
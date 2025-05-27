
import DestinyBlueprint
import Logging

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct StaticErrorResponder: ErrorResponderProtocol {
    public let logic:@Sendable (_ error: any Error) -> any StaticRouteResponderProtocol

    public init(_ logic: @escaping @Sendable (_ error: any Error) -> any StaticRouteResponderProtocol) {
        self.logic = logic
    }

    /// - Warning: Do not call.
    public var debugDescription: String { "" }

    @inlinable
    public func respond<S: HTTPSocketProtocol & ~Copyable, E: Error>(to socket: borrowing S, with error: E, for request: inout any HTTPRequestProtocol, logger: Logger) async {
        #if DEBUG
        logger.warning(Logger.Message(stringLiteral: "\(error)"))
        #endif
        do {
            try await logic(error).respond(to: socket)
        } catch {
            // TODO: do something
        }
    }
}
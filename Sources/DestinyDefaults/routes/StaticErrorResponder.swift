
import DestinyBlueprint
import Logging

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct StaticErrorResponder: ErrorResponderProtocol {
    public let logic:@Sendable (_ error: any Error) -> any StaticRouteResponderProtocol

    public init(_ logic: @escaping @Sendable (_ error: any Error) -> any StaticRouteResponderProtocol) {
        self.logic = logic
    }

    @inlinable
    public func respond<Socket: HTTPSocketProtocol & ~Copyable, E: Error>(
        socket: borrowing Socket,
        error: E,
        request: inout any HTTPRequestProtocol,
        logger: Logger
    ) async {
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
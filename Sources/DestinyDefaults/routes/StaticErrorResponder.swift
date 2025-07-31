
import DestinyBlueprint
import Logging

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct StaticErrorResponder: ErrorResponderProtocol {
    public let logic:@Sendable (_ error: any Error) -> any StaticRouteResponderProtocol

    public init(_ logic: @escaping @Sendable (_ error: any Error) -> any StaticRouteResponderProtocol) {
        self.logic = logic
    }

    @inlinable
    public func respond(
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger
    ) async {
        #if DEBUG
        logger.warning("\(error)")
        #endif
        do {
            try await logic(error).write(to: socket)
        } catch {
            // TODO: do something
        }
    }
}

import DestinyBlueprint
import Logging

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct NonCopyableStaticErrorResponder: NonCopyableErrorResponderProtocol, ~Copyable {
    public let logic:@Sendable (_ error: any Error) -> any NonCopyableStaticRouteResponderProtocol & ~Copyable

    public init(_ logic: @Sendable @escaping (_ error: any Error) -> any NonCopyableStaticRouteResponderProtocol & ~Copyable) {
        self.logic = logic
    }

    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        error: some Error,
        request: inout some HTTPRequestProtocol & ~Copyable,
        logger: Logger,
        completionHandler: @Sendable @escaping () -> Void
    ) {
        #if DEBUG
        logger.warning("\(error)")
        #endif
        do throws(ResponderError) {
            try logic(error).respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
        } catch {
            logger.error("[NonCopyableStaticErrorResponder] Encountered error trying to write response: \(error)")
        }
    }
}
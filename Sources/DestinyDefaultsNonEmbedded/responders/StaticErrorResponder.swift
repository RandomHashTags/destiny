
import DestinyBlueprint

#if Logging
import Logging
#endif

/// Default Error Responder implementation that does the bare minimum required to log and send an error response known at compile time.
public struct StaticErrorResponder: Sendable { // TODO: use behind a package trait
    public let logic:@Sendable (_ error: any Error) -> any StaticRouteResponderProtocol

    public init(_ logic: @Sendable @escaping (_ error: any Error) -> any StaticRouteResponderProtocol) {
        self.logic = logic
    }

    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        error: some Error,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) {
        #if DEBUG && Logging
        router.logger.warning("\(error)")
        #endif
        do throws(ResponderError) {
            try logic(error).respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
        } catch {
            #if Logging
            router.logger.error("[StaticErrorResponder] Encountered error trying to write response: \(error)")
            #endif
        }
    }
}

// MARK: Conformances
extension StaticErrorResponder: ErrorResponderProtocol {}
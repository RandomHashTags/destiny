
import DestinyBlueprint

/// Default Dynamic Middleware implementation which handles requests to dynamic routes.
public struct DynamicMiddleware: ExistentialDynamicMiddlewareProtocol {
    public let handleLogic:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws(MiddlewareError) -> Void
    package var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @Sendable @escaping (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws(MiddlewareError) -> Void
    ) {
        self.handleLogic = handleLogic
    }

    @inlinable
    public func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws(MiddlewareError) -> Bool {
        try await handleLogic(&request, &response)
        return true
    }

    public var debugDescription: String {
        "DynamicMiddleware \(logic)"
    }
}
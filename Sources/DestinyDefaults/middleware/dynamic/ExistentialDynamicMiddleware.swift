
import DestinyBlueprint

/// Default Existential Dynamic Middleware implementation which handles requests to dynamic routes.
public struct ExistentialDynamicMiddleware: ExistentialDynamicMiddlewareProtocol {
    public let handleLogic:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    package var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.handleLogic = handleLogic
    }

    @inlinable
    public func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws -> Bool {
        try await handleLogic(&request, &response)
        return true
    }

    public var debugDescription: String {
        "ExistentialDynamicMiddleware \(logic)"
    }
}
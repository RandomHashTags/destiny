
#if NonEmbedded

import DestinyBlueprint

/// Default Existential Dynamic Middleware implementation which handles requests to dynamic routes.
public struct ExistentialDynamicMiddleware {
    public let handleLogic:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) throws(MiddlewareError) -> Void
    package var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @Sendable @escaping (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) throws(MiddlewareError) -> Void
    ) {
        self.handleLogic = handleLogic
    }

    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        try handleLogic(&request, &response)
        return true
    }

    public var debugDescription: String {
        "ExistentialDynamicMiddleware \(logic)"
    }
}

// MARK: Conformances
extension ExistentialDynamicMiddleware: ExistentialDynamicMiddlewareProtocol {}

#endif
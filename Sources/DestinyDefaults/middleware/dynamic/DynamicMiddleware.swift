
#if !hasFeature(Embedded)

import DestinyBlueprint

/// Default Dynamic Middleware implementation which handles requests to dynamic routes.
public struct DynamicMiddleware: ExistentialDynamicMiddlewareProtocol {
    public let handleLogic:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) throws -> Void
    package var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @Sendable @escaping (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) throws -> Void
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
        do {
            try handleLogic(&request, &response)
        } catch {
            throw .init(identifier: "dynamicMiddlewareHandleError", reason: "\(error)")
        }
        return true
    }

    public var debugDescription: String {
        "DynamicMiddleware \(logic)"
    }
}

#endif
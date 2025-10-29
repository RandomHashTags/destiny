
#if NonEmbedded

import DestinyBlueprint

/// Default Dynamic Middleware implementation which handles requests to dynamic routes.
public struct DynamicMiddleware: Sendable {
    public let handleLogic:@Sendable (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) throws -> Void
    package var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @Sendable @escaping (_ request: inout HTTPRequest, _ response: inout any DynamicResponseProtocol) throws -> Void
    ) {
        self.handleLogic = handleLogic
    }

    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout HTTPRequest,
        response: inout any DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        do {
            try handleLogic(&request, &response)
        } catch {
            throw .custom("dynamicMiddlewareHandleError;\(error)")
        }
        return true
    }

    public var debugDescription: String {
        "DynamicMiddleware \(logic)"
    }
}

// MARK: Conformances
extension DynamicMiddleware: ExistentialDynamicMiddlewareProtocol {}

#endif
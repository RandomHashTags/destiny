
import DestinyEmbedded

/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: Sendable {
    public init() {
    }

    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        response.setHeader(key: "date", value: HTTPDateFormat.nowString)
        return true
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension DynamicDateMiddleware: OpaqueDynamicMiddlewareProtocol {}

#endif
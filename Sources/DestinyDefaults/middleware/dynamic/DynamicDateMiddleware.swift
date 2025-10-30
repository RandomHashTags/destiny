
import DestinyEmbedded

/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: Sendable {
    public init() {
    }

    /// Handle logic.
    /// 
    /// - Parameters:
    ///   - request: Incoming network request.
    ///   - response: Current response for the request.
    /// 
    /// - Returns: Whether or not to continue processing the request.
    /// - Throws: `MiddlewareError`
    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout HTTPRequest,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        response.setHeader(key: "date", value: HTTPDateFormat.nowString)
        return true
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension DynamicDateMiddleware: DynamicMiddlewareProtocol {}

#endif
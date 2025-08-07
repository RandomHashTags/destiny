
import DestinyBlueprint

/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: OpaqueDynamicMiddlewareProtocol {
    public init() {
    }

    @inlinable
    public func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) async -> Bool {
        response.setHeader(key: "Date", value: HTTPDateFormat.nowInlineArray.string())
        return true
    }
}
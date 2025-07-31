
import DestinyBlueprint

// MARK: DynamicDateMiddleware
/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: OpaqueDynamicMiddlewareProtocol {
    public init() {
    }

    @inlinable
    public func handle(request: inout some HTTPRequestProtocol & ~Copyable, response: inout some DynamicResponseProtocol) async throws -> Bool {
        response.setHeader(key: "Date", value: HTTPDateFormat.shared.nowInlineArray.string())
        return true
    }
}
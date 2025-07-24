
import DestinyBlueprint

// MARK: DynamicDateMiddleware
/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: DynamicMiddlewareProtocol {
    public init() {
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        response.setHeader(key: "Date", value: HTTPDateFormat.shared.nowInlineArray.string())
        return true
    }
}
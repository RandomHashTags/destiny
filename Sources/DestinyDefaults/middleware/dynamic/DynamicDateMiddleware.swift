
import DestinyBlueprint

/// Adds the `Date` header to responses for dynamic routes.
public struct DynamicDateMiddleware: OpaqueDynamicMiddlewareProtocol {
    public init() {
    }

    #if Inlinable
    @inlinable
    #endif
    public func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        response.setHeader(key: "date", value: HTTPDateFormat.nowInlineArray.unsafeString())
        return true
    }
}
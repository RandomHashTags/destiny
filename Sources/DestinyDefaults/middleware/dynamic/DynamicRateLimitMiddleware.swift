
import DestinyBlueprint

// MARK: DynamicRateLimitMiddleware
public final class DynamicRateLimitMiddleware: RateLimitMiddlewareProtocol, OpaqueDynamicMiddlewareProtocol, @unchecked Sendable { // TODO: finish (need a way to identify requests, preferably by IP address or persistent UUID)
    private var limits:[String:Int]

    public init() {
        limits = [:]
    }

    @inlinable
    public func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        return true
    }
}
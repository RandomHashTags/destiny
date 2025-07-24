
import DestinyBlueprint

// MARK: DynamicRateLimitMiddleware
public final class DynamicRateLimitMiddleware: RateLimitMiddlewareProtocol, DynamicMiddlewareProtocol, @unchecked Sendable { // TODO: finish (need a way to identify requests, preferably by IP address or persistent UUID)
    private var limits:[String:Int]

    public init() {
        limits = [:]
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        return true
    }
}
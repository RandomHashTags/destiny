
#if RateLimits


// TODO: finish
public final class DynamicRateLimitMiddleware: @unchecked Sendable {
    @usableFromInline
    var limits:[String:Entry]

    public init(
        technique: Technique
    ) {
        limits = [:]
    }
}

// MARK: Handle
extension DynamicRateLimitMiddleware {
    /// Handle logic.
    /// 
    /// - Parameters:
    ///   - request: Incoming network request.
    ///   - response: Current response for the request.
    /// 
    /// - Returns: Whether or not to continue processing the request.
    /// - Throws: `MiddlewareError`
    public func handle(
        request: inout HTTPRequest,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool {
        let id = (request.socketPeerAddress() ?? "")
        let entry = limits[id] ?? Entry(remainingLimit: 60)
        guard entry.remainingLimit > 0 else {
            // TODO: send "Too Many Requests" http message
            return false
        }
        entry.remainingLimit -= 1
        return true
    }
}

// MARK: Technique
extension DynamicRateLimitMiddleware {
    public enum Technique: Sendable {
        /// The Rate Limit applies to all requests as a whole, regardless of requested route.
        case collective

        /// The Rate Limit has different limits for different routes.
        case routeDependent
    }
}

// MARK: Entry
extension DynamicRateLimitMiddleware {
    @usableFromInline
    final class Entry: @unchecked Sendable {
        @usableFromInline
        var remainingLimit:Int

        @usableFromInline
        init(remainingLimit: Int) {
            self.remainingLimit = remainingLimit
        }
    }
}

#if Protocols

// MARK: Conformances
extension DynamicRateLimitMiddleware: DynamicMiddlewareProtocol {}

#endif

#endif
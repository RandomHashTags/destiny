
/// Core protocol that controls how many requests will be accepted for a route over a certain duration.
@_marker
public protocol RateLimitMiddlewareProtocol: MiddlewareProtocol, ~Copyable { // TODO: finish?
}
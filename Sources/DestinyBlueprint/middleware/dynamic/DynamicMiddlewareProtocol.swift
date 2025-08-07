
/// Core Dynamic Middleware protocol that handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
    /// Load logic when the middleware is ready to process requests.
    mutating func load()
}

extension DynamicMiddlewareProtocol {
    @inlinable
    public mutating func load() {
    }
}
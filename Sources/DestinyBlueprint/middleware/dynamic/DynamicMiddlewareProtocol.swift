
/// Core Dynamic Middleware protocol that handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
    /// Load logic when the middleware is ready to process requests.
    mutating func load()
}

extension DynamicMiddlewareProtocol {
    #if Inlinable
    @inlinable
    #endif
    public mutating func load() {
    }
}
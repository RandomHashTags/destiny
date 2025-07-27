
/// Core Dynamic Middleware protocol which handles requests to dynamic routes.
public protocol DynamicMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
    /// Load logic when the middleware is ready to process requests.
    @inlinable
    mutating func load()

    /// The handler.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    ///   - response: The current response for the request.
    /// - Returns: Whether or not to continue processing the request.
    @inlinable
    func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws -> Bool
}

extension DynamicMiddlewareProtocol {
    @inlinable
    public mutating func load() {
    }
}
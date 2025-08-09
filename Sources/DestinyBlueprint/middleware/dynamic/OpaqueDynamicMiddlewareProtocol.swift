
/// Core Dynamic Middleware protocol that handles dynamic requests and its response as opaque types.
public protocol OpaqueDynamicMiddlewareProtocol: DynamicMiddlewareProtocol, ~Copyable {
    /// The handler.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    ///   - response: The current response for the request.
    /// - Returns: Whether or not to continue processing the request.
    func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool
}
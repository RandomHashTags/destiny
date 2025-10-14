
/// Core protocol that handles dynamic requests and its response as opaque types.
public protocol OpaqueDynamicMiddlewareProtocol: DynamicMiddlewareProtocol, ~Copyable {
    /// Handle logic.
    /// 
    /// - Parameters:
    ///   - request: Incoming network request.
    ///   - response: Current response for the request.
    /// 
    /// - Returns: Whether or not to continue processing the request.
    /// - Throws: `MiddlewareError`
    func handle(
        request: inout some HTTPRequestProtocol & ~Copyable,
        response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool
}
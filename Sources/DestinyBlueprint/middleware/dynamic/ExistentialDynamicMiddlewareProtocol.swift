
public protocol ExistentialDynamicMiddlewareProtocol: DynamicMiddlewareProtocol, ~Copyable {
    /// The handler.
    /// 
    /// - Parameters:
    ///   - request: The incoming network request.
    ///   - response: The current response for the request.
    /// - Returns: Whether or not to continue processing the request.
    func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) async throws(MiddlewareError) -> Bool
}
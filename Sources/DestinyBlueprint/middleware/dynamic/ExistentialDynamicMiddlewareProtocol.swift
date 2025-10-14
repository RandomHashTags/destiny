
#if NonEmbedded

/// Core protocol that handles dynamic requests and its response as existential types.
public protocol ExistentialDynamicMiddlewareProtocol: DynamicMiddlewareProtocol, ~Copyable {
    /// Handle logic.
    /// 
    /// - Parameters:
    ///   - request: Incoming network request.
    ///   - response: Current response for the request.
    /// 
    /// - Returns: Whether or not to continue processing the request.
    /// - Throws: `MiddlewareError`
    func handle(
        request: inout any HTTPRequestProtocol,
        response: inout any DynamicResponseProtocol
    ) throws(MiddlewareError) -> Bool
}

#endif
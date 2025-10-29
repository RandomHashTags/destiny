
/// Core protocol that handles opaque dynamic middleware.
public protocol OpaqueDynamicMiddlewareStorageProtocol: DynamicMiddlewareStorageProtocol, ~Copyable {
    /// - Throws: `MiddlewareError`
    func handle(
        for request: inout HTTPRequest,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError)
}
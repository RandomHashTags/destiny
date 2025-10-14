
/// Core protocol that handles opaque dynamic middleware.
public protocol OpaqueDynamicMiddlewareStorageProtocol: DynamicMiddlewareStorageProtocol, ~Copyable {
    /// - Throws: `MiddlewareError`
    func handle(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError)
}
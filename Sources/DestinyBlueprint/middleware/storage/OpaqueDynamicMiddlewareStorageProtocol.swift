
/// Core immutable Dynamic Middleware Storage protocol that stores opaque dynamic middleware.
public protocol OpaqueDynamicMiddlewareStorageProtocol: DynamicMiddlewareStorageProtocol, ~Copyable {
    func handle(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError)
}
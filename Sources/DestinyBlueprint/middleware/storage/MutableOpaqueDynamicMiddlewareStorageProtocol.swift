
/// Core mutable Dynamic Middleware Storage protocol that handles opaque dynamic middleware.
public protocol MutableOpaqueDynamicMiddlewareStorageProtocol: AnyObject, OpaqueDynamicMiddlewareStorageProtocol {
    func register(
        _ middleware: some OpaqueDynamicMiddlewareProtocol
    )
}
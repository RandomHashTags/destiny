
/// Core mutable protocol that stores static middleware.
public protocol MutableStaticMiddlewareStorageProtocol: AnyObject, StaticMiddlewareStorageProtocol {
    /// Registers a static middleware.
    func register(
        _ middleware: some StaticMiddlewareProtocol
    ) throws(MiddlewareError)
}
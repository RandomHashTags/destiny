
public protocol MutableStaticMiddlewareStorageProtocol: AnyObject, StaticMiddlewareStorageProtocol {
    func register(
        _ middleware: some StaticMiddlewareProtocol
    ) throws(MiddlewareError)
}
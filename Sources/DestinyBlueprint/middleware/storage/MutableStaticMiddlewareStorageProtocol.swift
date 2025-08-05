
public protocol MutableStaticMiddlewareStorageProtocol: StaticMiddlewareStorageProtocol, AnyObject {
    func register(
        _ middleware: some StaticMiddlewareProtocol
    ) throws(MiddlewareError)
}
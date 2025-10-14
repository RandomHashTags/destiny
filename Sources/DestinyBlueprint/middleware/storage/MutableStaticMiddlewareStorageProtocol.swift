
#if MutableRouter && StaticMiddleware

/// Core mutable protocol that stores static middleware.
public protocol MutableStaticMiddlewareStorageProtocol: AnyObject, StaticMiddlewareStorageProtocol {
    /// Registers a static middleware.
    /// 
    /// - Throws: `MiddlewareError`
    func register(
        _ middleware: some StaticMiddlewareProtocol
    ) throws(MiddlewareError)
}

#endif

import DestinyBlueprint

/// Default immutable Static Middleware storage that handles static middleware.
public struct CompiledStaticMiddlewareStorage<each ConcreteMiddleware: StaticMiddlewareProtocol>: StaticMiddlewareStorageProtocol {
    public let middleware:(repeat each ConcreteMiddleware)

    public init(_ middleware: (repeat each ConcreteMiddleware)) {
        self.middleware = middleware
    }

    @inlinable
    public func forEach(_ closure: (any StaticMiddlewareProtocol) -> Void) {
        for middleware in repeat each middleware {
            closure(middleware)
        }
    }
}
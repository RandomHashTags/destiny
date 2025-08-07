
import DestinyBlueprint

/// Default immutable Dynamic Middleware storage that handles dynamic middleware.
public struct CompiledDynamicMiddlewareStorage<each ConcreteMiddleware: DynamicMiddlewareProtocol>: DynamicMiddlewareStorageProtocol {
    public let middleware:(repeat each ConcreteMiddleware)

    public init(_ middleware: (repeat each ConcreteMiddleware)) {
        self.middleware = middleware
    }

    @inlinable
    public func forEach(_ closure: (any DynamicMiddlewareProtocol) -> Void) {
        for middleware in repeat each middleware {
            closure(middleware)
        }
    }
}
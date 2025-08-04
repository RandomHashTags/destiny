
import DestinyBlueprint

/// Default immutable storage that handles dynamic middleware.
public struct CompiledDynamicMiddlewareStorage<each ConcreteMiddleware: DynamicMiddlewareProtocol>: ImmutableDynamicMiddlewareStorageProtocol {
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
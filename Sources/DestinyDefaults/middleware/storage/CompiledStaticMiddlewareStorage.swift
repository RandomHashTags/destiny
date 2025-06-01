
import DestinyBlueprint

/// Default immutable storage that handles static middleware.
public struct CompiledStaticMiddlewareStorage<each ConcreteMiddleware: StaticMiddlewareProtocol>: StaticMiddlewareStorageProtocol {
    public let middleware:(repeat each ConcreteMiddleware)

    public init(_ middleware: (repeat each ConcreteMiddleware)) {
        self.middleware = middleware
    }
}

import DestinyBlueprint

public final class StaticMiddlewareStorage: MutableStaticMiddlewareStorageProtocol, @unchecked Sendable {
    @usableFromInline
    var middleware:[any StaticMiddlewareProtocol]

    public init(_ middleware: [any StaticMiddlewareProtocol]) {
        self.middleware = middleware
    }
}

// MARK: For each
extension StaticMiddlewareStorage {
    @inlinable
    public func forEach(_ closure: (any StaticMiddlewareProtocol) -> Void) {
        for m in middleware {
            closure(m)
        }
    }
}

// MARK: Register
extension StaticMiddlewareStorage {
    @inlinable
    public func register(
        _ middleware: some StaticMiddlewareProtocol
    ) throws(MiddlewareError) {
        self.middleware.append(middleware)
    }
}
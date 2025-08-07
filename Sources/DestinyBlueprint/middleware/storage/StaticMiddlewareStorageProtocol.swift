
/// Core immutable Static Middleware Storage protocol that stores static middleware.
public protocol StaticMiddlewareStorageProtocol: Sendable, ~Copyable {
    /// Iterates over the stored static middleware.
    func forEach(
        _ closure: (any StaticMiddlewareProtocol) -> Void
    )
}
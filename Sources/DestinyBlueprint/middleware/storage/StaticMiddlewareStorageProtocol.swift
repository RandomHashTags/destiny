
#if StaticMiddleware

/// Core protocol that stores static middleware.
public protocol StaticMiddlewareStorageProtocol: Sendable, ~Copyable { // TODO: avoid existentials / support embedded
    /// Iterates over the stored static middleware.
    func forEach(
        _ closure: (any StaticMiddlewareProtocol) -> Void
    )
}

#endif
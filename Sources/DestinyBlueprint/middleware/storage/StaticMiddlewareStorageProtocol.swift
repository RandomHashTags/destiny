
public protocol StaticMiddlewareStorageProtocol: Sendable, ~Copyable {
    func forEach(
        _ closure: (any StaticMiddlewareProtocol) -> Void
    )
}
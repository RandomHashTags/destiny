
/// Core File Middleware protocol that allows files to be read.
public protocol FileMiddlewareProtocol: Sendable, ~Copyable { // TODO: finish
    func load()
}
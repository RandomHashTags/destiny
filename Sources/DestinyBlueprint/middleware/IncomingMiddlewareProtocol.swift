
/// Middleware protocol that can only modify incoming HTTP Messages.
@_marker
public protocol IncomingMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
}
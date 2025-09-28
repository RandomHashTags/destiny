
/// Middleware protocol that can only modify outgoing HTTP Messages.
@_marker
public protocol OutgoingMiddlewareProtocol: MiddlewareProtocol, ~Copyable {
}
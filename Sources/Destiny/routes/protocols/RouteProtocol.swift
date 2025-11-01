
/// Core protocol that indicates it as a route.
public protocol RouteProtocol: Sendable, ~Copyable {
    /// Whether or not the path for this route is case-sensitive.
    var isCaseSensitive: Bool { get }
}
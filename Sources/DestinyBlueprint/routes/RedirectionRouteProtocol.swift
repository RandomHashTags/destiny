
/// Core protocol that redirects endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol, ~Copyable {
    /// The http start line this route redirects from.
    func fromStartLine() -> String
}
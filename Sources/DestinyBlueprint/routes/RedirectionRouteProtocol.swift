
/// Core Redirection Route protocol that redirects certain endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol, ~Copyable {
    /// The http start line this route redirects from.
    func fromStartLine() -> String

    /// The HTTP Message of this route. Computed at compile time.
    /// 
    /// - Throws: `AnyError`; if thrown: a compile diagnostic is shown describing the issue.
    /// - Returns: a string representing a complete HTTP Message.
    func response() throws(AnyError) -> String
}
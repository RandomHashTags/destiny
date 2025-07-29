
/// Core Redirection Route protocol that redirects certain endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol, ~Copyable {
    /// New route path this route redirects to.
    func newLocationPath() -> String

    /// The HTTP Message of this route. Computed at compile time.
    /// 
    /// - Throws: any error; if thrown: a compile diagnostic shown describing the issue.
    /// - Returns: a string representing a complete HTTP Message.
    func response() throws -> String
}
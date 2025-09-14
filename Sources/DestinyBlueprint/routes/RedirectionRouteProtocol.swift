
/// Core protocol that redirects endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol, ~Copyable {
    associatedtype Message:HTTPMessageProtocol

    /// The http start line this route redirects from.
    func fromStartLine() -> String

    /// The HTTP Message of this route. Computed at compile time.
    /// 
    /// - Throws: `AnyError`; if thrown: a compile diagnostic is shown describing the issue.
    func response() throws(AnyError) -> Message
}
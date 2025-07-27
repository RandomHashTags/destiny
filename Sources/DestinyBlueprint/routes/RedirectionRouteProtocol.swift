
/// Core Redirection Route protocol that redirects certain endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol {
    /// The endpoint that has been moved.
    var from: [String] { get }

    /// The redirection endpoint.
    var to: [String] { get }

    /// Status of this redirection route.
    var status: HTTPResponseStatus.Code { get }

    /// The HTTP Message of this route. Computed at compile time.
    /// 
    /// - Throws: any error; if thrown: a compile diagnostic shown describing the issue.
    /// - Returns: a string representing a complete HTTP Message.
    func response() throws -> String
}
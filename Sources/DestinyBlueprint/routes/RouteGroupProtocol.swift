
/// Core Route Group protocol that handles routes grouped by a single endpoint.
public protocol RouteGroupProtocol: Sendable, ~Copyable {

    /// - Returns: Whether or not this router group responded to the request.
    func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool
}
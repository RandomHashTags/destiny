
#if NonCopyable

/// Core protocol that handles requests to dynamic routes.
public protocol NonCopyableDynamicRouteResponderProtocol: NonCopyableRouteResponderProtocol, ~Copyable {
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol

    /// - Returns: The `PathComponent` located at the given index.
    /// - Warning: **Does no bounds checking**.
    func pathComponent(at index: Int) -> PathComponent

    /// Number of path components this route contains.
    var pathComponentsCount: Int { get }

    /// Yields the indexes where a parameter is located in the path.
    func forEachPathComponentParameterIndex(_ yield: (Int) -> Void)

    /// Default `DynamicResponseProtocol` value computed at compile time taking into account all static middleware.
    func defaultResponse() -> ConcreteDynamicResponse

    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - request: Socket's request.
    ///   - response: HTTP message to send to the socket.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest,
        response: inout some DynamicResponseProtocol
    ) throws(ResponderError)
}

// MARK: Defaults
extension NonCopyableDynamicRouteResponderProtocol where Self: ~Copyable {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        try router.respond(provider: provider, request: &request, responder: self)
    }
}

#endif
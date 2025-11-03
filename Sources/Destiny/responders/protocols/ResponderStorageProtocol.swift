

/// Core protocol that stores route responders.
public protocol ResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - provider: Socket's provider.
    ///   - router: Router this storage belongs to.
    ///   - request: Socket's request.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `DestinyError`
    func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(DestinyError) -> Bool
}

public protocol RouterResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws -> Bool

    /// Try to write a response to a socket, only checking static storage.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - startLine: The socket's target endpoint.
    /// - Returns: Whether or not a response was sent.
    func respondStatically(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool

    /// Try to write a response to a socket, only checking dynamic storage.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    /// - Returns: Whether or not a response was sent.
    func respondDynamically(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
    ) async throws -> Bool
}
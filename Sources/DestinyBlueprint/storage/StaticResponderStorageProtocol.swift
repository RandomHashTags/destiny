
public protocol StaticResponderStorageProtocol: Sendable, ~Copyable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - startLine: The socket's requested endpoint.
    /// - Returns: Whether or not a response was sent.
    func respond(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool
}
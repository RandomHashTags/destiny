
public protocol StaticResponderStorageProtocol: CustomDebugStringConvertible, Sendable {
    /// Try to write a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this storage belongs to.
    ///   - socket: The socket to write to.
    ///   - startLine: The socket's requested endpoint.
    /// - Returns: Whether or not a response was sent.
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool
}
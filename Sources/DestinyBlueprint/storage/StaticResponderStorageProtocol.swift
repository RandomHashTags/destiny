
public protocol StaticResponderStorageProtocol: CustomDebugStringConvertible, Sendable {
    /// - Returns: Whether or not a response was sent.
    @inlinable
    func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool
}
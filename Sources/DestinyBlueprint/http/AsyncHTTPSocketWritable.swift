
/// Types conforming to this protocol can write their contents asynchronously to an HTTP Socket.
public protocol AsyncHTTPSocketWritable: Sendable, ~Copyable {
    /// Asynchronously writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    func write(
        to socket: Int32
    ) async throws(SocketError)
}

extension AsyncHTTPSocketWritable {
    /// Asynchronously writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: some noncopyable `HTTPSocketProtocol`.
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        try await write(to: socket.fileDescriptor)
    }
}

// MARK: Default conformances
extension String: AsyncHTTPSocketWritable {
    @inlinable
    public func write(
        to socket: Int32
    ) async throws(SocketError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: AsyncHTTPSocketWritable {
    @inlinable
    public func write(
        to socket: Int32
    ) async throws(SocketError) {
        var err:SocketError? = nil
        withUTF8Buffer {
            do throws(SocketError) {
                try socket.socketWriteBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
}

extension [UInt8]: AsyncHTTPSocketWritable {
    @inlinable
    public func write(
        to socket: Int32
    ) async throws(SocketError) {
        var err:SocketError? = nil
        self.withUnsafeBufferPointer {
            do throws(SocketError) {
                try socket.socketWriteBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
}
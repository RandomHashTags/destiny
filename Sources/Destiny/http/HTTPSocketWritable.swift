
/// Types conforming to this protocol can write their contents synchronously to a `FileDescriptor`.
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Synchronously writes data to the file descriptor.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    /// 
    /// - Throws: `SocketError`
    func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(SocketError)
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(SocketError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(SocketError) {
        try socket.socketWriteBuffer(utf8Start, length: utf8CodeUnitCount)
    }
}

extension [UInt8]: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(SocketError) {
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
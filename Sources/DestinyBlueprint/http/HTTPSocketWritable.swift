
/// Types conforming to this protocol can write their contents synchronously to an HTTP Socket.
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Synchronously writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    func write(
        to socket: some FileDescriptor
    ) throws(SocketError)
}

extension HTTPSocketWritable {
    @inlinable
    public func write(to socket: some FileDescriptor) throws(SocketError) {
        try write(to: socket.fileDescriptor)
    }
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
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

extension [UInt8]: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: some FileDescriptor
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
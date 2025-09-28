
/// Types conforming to this protocol can write their contents synchronously to a `FileDescriptor`.
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Synchronously writes data to the file descriptor.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    func write(
        to socket: some FileDescriptor
    ) throws(SocketError)
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to socket: some FileDescriptor
    ) throws(SocketError) {
        try socket.socketWriteBuffer(utf8Start, length: utf8CodeUnitCount)
    }
}

extension [UInt8]: HTTPSocketWritable {
    #if Inlinable
    @inlinable
    #endif
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
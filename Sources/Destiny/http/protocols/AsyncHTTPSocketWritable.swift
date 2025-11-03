

/// Types conforming to this protocol can write their contents asynchronously to a `FileDescriptor`.
public protocol AsyncHTTPSocketWritable: Sendable, ~Copyable {
    /// Asynchronously writes data to the file descriptor.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) async throws(DestinyError)
}

extension AsyncHTTPSocketWritable {
    /// Asynchronously writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: some noncopyable `FileDescriptor`.
    /// 
    /// - Throws: `DestinyError`
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) async throws(DestinyError) {
        try await write(to: socket.fileDescriptor)
    }
}

// MARK: Default conformances
extension String: AsyncHTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) async throws(DestinyError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: AsyncHTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) async throws(DestinyError) {
        try socket.socketWriteBuffer(utf8Start, length: utf8CodeUnitCount)
    }
}

extension [UInt8]: AsyncHTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) async throws(DestinyError) {
        var err:DestinyError? = nil
        self.withUnsafeBufferPointer {
            do throws(DestinyError) {
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
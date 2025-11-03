
/// Types conforming to this protocol can write their contents synchronously to a `FileDescriptor`.
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Synchronously writes data to the file descriptor.
    /// 
    /// - Parameters:
    ///   - socket: The socket.
    /// 
    /// - Throws: `DestinyError`
    func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(DestinyError)
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(DestinyError) {
        try socket.socketWriteString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(DestinyError) {
        try socket.socketWriteBuffer(utf8Start, length: utf8CodeUnitCount)
    }
}

extension [UInt8]: HTTPSocketWritable {
    public func write(
        to socket: borrowing some FileDescriptor & ~Copyable
    ) throws(DestinyError) {
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

public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: some noncopyable `HTTPSocketProtocol`.
    func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try socket.writeString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        var err:(any Error)? = nil
        withUTF8Buffer {
            do {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
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
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try self.withUnsafeBufferPointer {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
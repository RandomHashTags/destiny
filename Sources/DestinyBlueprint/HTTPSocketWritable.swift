
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Writes data to a socket.
    func write<Socket: HTTPSocketProtocol & ~Copyable>(
        to socket: borrowing Socket
    ) async throws
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try socket.writeString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
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

/*
extension Int64: HTTPSocketWritable {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try withUnsafeBytes(of: self, {
            try socket.writeBuffer($0.baseAddress!, length: 64)
        })
    }
}*/
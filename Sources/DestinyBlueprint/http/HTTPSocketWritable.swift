
public protocol HTTPSocketWritable: Sendable, ~Copyable {
    /// Writes data to the socket.
    /// 
    /// - Parameters:
    ///   - socket: some noncopyable `HTTPSocketProtocol`.
    func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError)
}

// MARK: Default conformances
extension String: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        try socket.writeString(self)
    }
}

extension StaticString: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        var err:SocketError? = nil
        withUTF8Buffer {
            do throws(SocketError) {
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
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        var err:SocketError? = nil
        self.withUnsafeBufferPointer {
            do throws(SocketError) {
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
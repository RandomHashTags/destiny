
/// Core protocol that handles incoming network data.
public protocol SocketProtocol: FileDescriptor, ~Copyable {
    init(fileDescriptor: Int32)
}

extension SocketProtocol where Self: ~Copyable {
    #if Inlinable
    @inlinable
    #endif
    public static func noSigPipe(fileDescriptor: Int32) {
        #if canImport(Darwin)
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }

    /// Writes a `String` to the file descriptor.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public func writeString(
        _ string: String
    ) throws(SocketError) {
        try fileDescriptor.socketWriteString(string)
    }
}
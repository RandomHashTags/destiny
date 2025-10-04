
/// Core protocol that handles incoming network requests.
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

    #if Inlinable
    @inlinable
    #endif
    public func socketLocalAddress() -> String? {
        fileDescriptor.socketLocalAddress()
    }

    #if Inlinable
    @inlinable
    #endif
    public func socketPeerAddress() -> String? {
        fileDescriptor.socketPeerAddress()
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers(buffers)
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, (buffer: UnsafePointer<UInt8>, bufferCount: Int)>
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers(buffers)
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeString(
        _ string: String
    ) throws(SocketError) {
        try fileDescriptor.socketWriteString(string)
    }
}
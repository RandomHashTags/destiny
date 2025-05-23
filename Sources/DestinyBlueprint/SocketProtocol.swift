
#if canImport(Darwin)
import Darwin
#endif

/// Core Socket protocol that handles incoming network requests.
public protocol SocketProtocol: ~Copyable, Sendable {
    associatedtype Buffer:InlineArrayProtocol where Buffer.Element == UInt8

    associatedtype ConcreteRequest:RequestProtocol
    
    /// The unique file descriptor the system assigns to this socket where communication between the server and client are handled.
    /// 
    /// - Warning: Do not close this file descriptor. It is closed automatically by the server.
    var fileDescriptor: Int32 { get }

    init(fileDescriptor: Int32)

    /// Reads a buffer from the socket.
    @inlinable
    func readBuffer(
        into baseAddress: UnsafeMutablePointer<UInt8>,
        length: Int,
        flags: Int32
    ) throws -> Int

    @inlinable
    func readBuffer() throws -> (Buffer, Int)

    /// Writes a buffer to the socket.
    @inlinable
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws

    @inlinable
    func writeString(_ string: String) throws
}

extension SocketProtocol where Self: ~Copyable {
    @inlinable
    public static func noSigPipe(fileDescriptor: Int32) {
        #if canImport(Darwin)
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }

    @inlinable
    public func writeString(_ string: String) throws {
        try string.utf8.withContiguousStorageIfAvailable {
            try self.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
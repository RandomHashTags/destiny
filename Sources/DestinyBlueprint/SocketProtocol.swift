
#if canImport(Darwin)
import Darwin
#endif

/// Core Socket protocol that handles incoming network requests.
public protocol SocketProtocol: ~Copyable, Sendable {
    associatedtype Buffer:InlineArrayProtocol where Buffer.Element == UInt8
    
    /// The unique file descriptor the system assigns to this socket where communication between the server and client are handled.
    /// 
    /// - Warning: Do not close this file descriptor. It is closed automatically by the server.
    var fileDescriptor: Int32 { get }

    init(fileDescriptor: Int32)

    /// Reads a buffer from the socket.
    func readBuffer(
        into baseAddress: UnsafeMutablePointer<UInt8>,
        length: Int,
        flags: Int32
    ) throws -> Int

    func readBuffer() throws -> (Buffer, Int)

    /// Writes a buffer to the socket.
    func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws

    /// Writes a `String` to the socket.
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

    /// Writes 2 bytes (carriage return and line feed) to the socket.
    @inlinable
    public func writeCRLF(count: Int = 1) throws {
        let capacity = count * 2
        try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            while i < count {
                p[i] = .carriageReturn
                p[i + 1] = .lineFeed
                i += 2
            }
            try writeBuffer(p.baseAddress!, length: capacity)
        })
    }

    @inlinable
    public func writeString(_ string: String) throws {
        try string.utf8.withContiguousStorageIfAvailable {
            try self.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}
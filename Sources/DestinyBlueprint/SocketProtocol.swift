
#if canImport(Darwin)
import Darwin
#endif

/// Core Socket protocol that handles incoming network requests.
public protocol SocketProtocol: ~Copyable, Sendable {
    associatedtype Buffer:InlineByteArrayProtocol
    
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
    ) throws(SocketError) -> Int

    func readBuffer() throws(SocketError) -> (Buffer, Int)

    /// Writes a buffer to the socket.
    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError)

    /// Writes multiple buffers to the socket utilizing `writev`.
    func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError)

    /// Writes a `String` to the socket.
    func writeString(
        _ string: String
    ) throws(SocketError)
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
    public func writeCRLF(
        count: Int = 1
    ) throws(SocketError) {
        let capacity = count * 2
        var err:SocketError? = nil
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            while i < count {
                p[i] = .carriageReturn
                p[i + 1] = .lineFeed
                i += 2
            }
            do throws(SocketError) {
                try writeBuffer(p.baseAddress!, length: capacity)
            } catch {
                err = error
            }
        })
        if let err {
            throw err
        }
    }

    @inlinable
    public func writeString(
        _ string: String
    ) throws(SocketError) {
        var err:SocketError? = nil
        string.utf8.withContiguousStorageIfAvailable {
            do throws(SocketError) {
                try self.writeBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }
}
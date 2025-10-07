
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

import UnwrapArithmeticOperators

/// Types conforming to this protocol indicate they behave like a file descriptor.
public protocol FileDescriptor: NetworkAddressable, ~Copyable {
    /// Unique file descriptor of this socket where communication between the server and client are handled.
    /// 
    /// - Warning: Don't forget to close when you're done with it. It is **not** closed automatically.
    var fileDescriptor: Int32 { get }

    /// Reads multiple bytes and writes them into a buffer.
    /// 
    /// - Returns: Number of bytes received.
    func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32
    ) throws(SocketError) -> Int

    /// Writes a single buffer to the file descriptor.
    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError)

    /// Efficiently writes multiple buffers to the file descriptor.
    func writeBuffers3(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError)

    /// Efficiently writes multiple buffers to the file descriptor.
    func writeBuffers4(
        _ b1: UnsafeBufferPointer<UInt8>,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: UnsafeBufferPointer<UInt8>,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(SocketError)

    /// Efficiently writes multiple buffers to the file descriptor.
    func writeBuffers6(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError)

    func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) -> Int
    func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int
    func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int
}

// MARK: Write
extension FileDescriptor where Self: ~Copyable {
    #if Inlinable
    @inlinable
    #endif
    public func socketWriteBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            let result = socketSendMultiplatform(pointer: pointer + sent, length: length -! sent)
            if result <= 0 {
                throw .custom("writeFailed;result <= 0")
            }
            sent +=! result
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func socketWriteString(
        _ string: String
    ) throws(SocketError) {
        var err:SocketError? = nil
        string.utf8Span.span.withUnsafeBufferPointer {
            do throws(SocketError) {
                try socketWriteBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers3(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        var iovecs = (
            iovec(iov_base: .init(mutating: b1.0), iov_len: b1.1),
            iovec(iov_base: .init(mutating: b2.0), iov_len: b2.1),
            iovec(iov_base: .init(mutating: b3.0), iov_len: b3.1)
        )
        let result = withUnsafePointer(to: &iovecs) {
            writev(fileDescriptor, UnsafePointer<iovec>(OpaquePointer($0)), 3)
        }
        if result <= 0 {
            throw .writeFailed(errno: errno)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers4(
        _ b1: UnsafeBufferPointer<UInt8>,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: UnsafeBufferPointer<UInt8>,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(SocketError) {
        var iovecs = (
            iovec(iov_base: .init(mutating: b1.baseAddress), iov_len: b1.count),
            iovec(iov_base: .init(mutating: b2.baseAddress), iov_len: b2.count),
            iovec(iov_base: .init(mutating: b3.baseAddress), iov_len: b3.count),
            iovec(iov_base: .init(mutating: b4.baseAddress), iov_len: b4.count)
        )
        let result = withUnsafePointer(to: &iovecs) {
            writev(fileDescriptor, UnsafePointer<iovec>(OpaquePointer($0)), 4)
        }
        if result <= 0 {
            throw .writeFailed(errno: errno)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers6(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        var iovecs = (
            iovec(iov_base: .init(mutating: b1.0), iov_len: b1.1),
            iovec(iov_base: .init(mutating: b2.0), iov_len: b2.1),
            iovec(iov_base: .init(mutating: b3.0), iov_len: b3.1),
            iovec(iov_base: .init(mutating: b4.0), iov_len: b4.1),
            iovec(iov_base: .init(mutating: b5.0), iov_len: b5.1),
            iovec(iov_base: .init(mutating: b6.0), iov_len: b6.1)
        )
        let result = withUnsafePointer(to: &iovecs) {
            writev(fileDescriptor, UnsafePointer<iovec>(OpaquePointer($0)), 6)
        }
        if result <= 0 {
            throw .writeFailed(errno: errno)
        }
    }
}

// MARK: Close
extension FileDescriptor {
    #if Inlinable
    @inlinable
    #endif
    package func socketClose() {
        #if canImport(SwiftGlibc) || canImport(Foundation)
        shutdown(fileDescriptor, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
        close(fileDescriptor)
        #else
        #warning("Unable to shutdown and close file descriptor!")
        #endif
    }
}
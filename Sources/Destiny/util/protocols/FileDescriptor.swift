
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

#if Epoll
import CEpoll
#endif

import UnwrapArithmeticOperators

/// Types conforming to this protocol indicate they behave like a file descriptor.
public protocol FileDescriptor: NetworkAddressable, ~Copyable {
    /// Unique file descriptor of this socket where communication between the server and client are handled.
    /// 
    /// - Warning: Don't forget to close when you're done with it. It is **not** closed automatically.
    var fileDescriptor: Int32 { get }

    /// Reads and writes multiple bytes from the file descriptor into a buffer.
    /// 
    /// - Parameters:
    ///   - into: The `UnsafeMutableRawPointer` the bytes will be written to.
    ///   - length: Number of bytes to read.
    ///   - flags: Applied flags when reading.
    /// 
    /// - Returns: Number of bytes received.
    /// - Throws: `DestinyError`
    func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32
    ) throws(DestinyError) -> Int

    /// Writes a single buffer to the file descriptor.
    /// 
    /// - Throws: `DestinyError`
    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(DestinyError)

    /// Efficiently writes 3 buffers to the file descriptor.
    /// 
    /// - Throws: `DestinyError`
    func writeBuffers3(
        _ b1: iovec,
        _ b2: iovec,
        _ b3: iovec
    ) throws(DestinyError)

    /// Efficiently writes 4 buffers to the file descriptor.
    /// 
    /// - Throws: `DestinyError`
    func writeBuffers4(
        _ b1: iovec,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: iovec,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(DestinyError)

    /// Efficiently writes 6 buffers to the file descriptor.
    /// 
    /// - Throws: `DestinyError`
    func writeBuffers6(
        _ b1: iovec,
        _ b2: iovec,
        _ b3: iovec,
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: iovec,
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(DestinyError)

    func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) -> Int
    func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int
    func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int

    /// Flushes (drains) all pending data from the file descriptor.
    /// 
    /// If using epoll: keeps reading until `read()` returns EAGAIN/EWOULDBLOCK or the connection is closed.
    func flush(provider: some SocketProvider)

    func close()
}

// MARK: Write
extension FileDescriptor where Self: ~Copyable {
    public static func noSigPipe(fileDescriptor: Int32) {
        #if canImport(Darwin)
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }

    public func socketWriteBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(DestinyError) {
        var sent = 0
        while sent < length {
            let result = socketSendMultiplatform(pointer: pointer + sent, length: length -! sent)
            if result <= 0 {
                throw .custom("writeFailed;result <= 0")
            }
            sent +=! result
        }
    }

    public func socketWriteString(
        _ string: String
    ) throws(DestinyError) {
        var err:DestinyError? = nil
        string.withContiguousStorageIfAvailable {
            do throws(DestinyError) {
                try socketWriteBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
    }

    // MARK: Flush
    public func flush(provider: some SocketProvider) {
        #if DEBUG
        print("FileDescriptor;flush;flushing \(fileDescriptor)")
        #endif
        var inlineArray = [1024 of UInt8](repeating: 0)
        var mutableSpan = inlineArray.mutableSpan
        mutableSpan.withUnsafeMutableBufferPointer { buffer in
            while true {
                let bytesRead = read(fileDescriptor, buffer.baseAddress, buffer.count)
                guard bytesRead <= 0 else { continue }

                if bytesRead == 0 {
                    // peer closed socket
                    close()
                    return
                }

                #if Epoll
                if errno == EAGAIN || errno == EWOULDBLOCK { // successfully flushed
                    provider.rearm(fd: fileDescriptor)
                    return
                }
                #endif

                // socket error — recommend closing
                close()
                return
            }
        }
        #if DEBUG
        print("FileDescriptor;flush;flushed=\(fileDescriptor)")
        #endif
    }
}

// MARK: Close
extension FileDescriptor where Self: ~Copyable {
    package func socketClose() {
        #if canImport(SwiftGlibc) || canImport(Foundation)

        shutdown(fileDescriptor, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
        #if canImport(SwiftGlibc)
        SwiftGlibc.close(fileDescriptor)
        #else
        Foundation.close(fileDescriptor)
        #endif

        #if DEBUG
        print("FileDescriptor;socketClose;closed \(fileDescriptor)")
        #endif

        #else
        #warning("Unable to shutdown and close file descriptor!")
        #endif
    }
}
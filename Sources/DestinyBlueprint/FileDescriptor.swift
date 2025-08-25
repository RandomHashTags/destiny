
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

public protocol FileDescriptor: Sendable {
    var fileDescriptor: Int32 { get }

    /// Reads multiple bytes and writes them into a buffer.
    /// 
    /// - Returns: The number of bytes received.
    func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32
    ) throws(SocketError) -> Int

    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError)

    func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError)
}

// MARK: Int32
extension Int32: FileDescriptor {
    @inlinable
    public var fileDescriptor: Int32 {
        self
    }

    @inlinable
    public func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32
    ) throws(SocketError) -> Int {
        let read = socketReceive(baseAddress, length, flags)
        if read < 0 { // error
            try handleReadError()
        }
        return read
    }

    @inlinable
    public func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            let result = socketSendMultiplatform(pointer + sent, length - sent)
            if result <= 0 {
                throw .writeFailed()
            }
            sent += result
        }
    }

    @inlinable
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError) {
        var err:SocketError? = nil
        withUnsafeTemporaryAllocation(of: iovec.self, capacity: count, { iovecs in
            for i in buffers.indices {
                let buffer = buffers[i]
                iovecs[i] = .init(iov_base: .init(mutating: buffer.baseAddress), iov_len: buffer.count)
            }
            let result = writev(fileDescriptor, iovecs.baseAddress, Int32(count))
            if result <= 0 {
                err = SocketError.writeFailed()
            }
        })
        if let err {
            throw err
        }
    }
}



// MARK: Receive
extension FileDescriptor {
    @inlinable
    public func socketReceive(_ baseAddress: UnsafeMutablePointer<UInt8>, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    @inlinable
    public func socketReceive(_ baseAddress: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Read
extension FileDescriptor {
    @inlinable
    package func handleReadError() throws(SocketError) {
        #if canImport(Glibc)
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #endif
        throw SocketError.readBufferFailed()
    }
}

// MARK: Write
extension FileDescriptor {
    @inlinable
    public func socketWriteBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            let result = socketSendMultiplatform(pointer + sent, length - sent)
            if result <= 0 {
                throw .writeFailed()
            }
            sent += result
        }
    }

    @inlinable
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
}

// MARK: Send
extension FileDescriptor {
    @inlinable
    package func socketSendMultiplatform(_ pointer: UnsafeRawPointer, _ length: Int) -> Int {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return send(fileDescriptor, pointer, length, Int32(MSG_NOSIGNAL))
        #else
        return write(self, pointer, length)
        #endif
    }
}

// MARK: Close
extension FileDescriptor {
    @inlinable
    package func socketClose() {
        #if canImport(SwiftGlibc) || canImport(Foundation)
        shutdown(fileDescriptor, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
        close(fileDescriptor)
        #else
        #warning("Unable to shutdown and close file descriptor!")
        #endif
    }
}
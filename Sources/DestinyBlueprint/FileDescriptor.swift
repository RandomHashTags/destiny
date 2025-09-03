
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

    /// Writes a single buffer to the file descriptor.
    func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError)

    /// Efficiently writes multiple buffers to the file descriptor.
    func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError)

    /// - Returns: The local socket address of this file descriptor.
    func socketLocalAddress() -> String?

    /// - Returns: The peer socket address of this file descriptor.
    func socketPeerAddress() -> String?
}

// MARK: Int32
extension Int32: FileDescriptor {
    #if Inlinable
    @inlinable
    #endif
    public var fileDescriptor: Int32 {
        self
    }

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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

// MARK: Address
extension Int32 {
    #if Inlinable
    @inlinable
    #endif
    public func socketLocalAddress() -> String? {
        var addr = sockaddr_storage()
        var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let result = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                return getsockname(self, sa, &len)
            }
        }
        return socketAddress(addr: &addr, result: result)
    }

    #if Inlinable
    @inlinable
    #endif
    public func socketPeerAddress() -> String? {
        var addr = sockaddr_storage()
        var len = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let result = withUnsafeMutablePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                return getpeername(self, sa, &len)
            }
        }
        return socketAddress(addr: &addr, result: result)
    }

    #if Inlinable
    @inlinable
    #endif
    func socketAddress(addr: inout sockaddr_storage, result: Int32) -> String? {
        if result != 0 {
            return nil
        }
        if addr.ss_family == sa_family_t(AF_INET) { // IPv4
            return withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sa in
                    return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: Int(INET_ADDRSTRLEN), { buffer in
                        var addr = sa.pointee.sin_addr
                        inet_ntop(AF_INET, &addr, buffer.baseAddress, socklen_t(INET_ADDRSTRLEN))
                        return String(decoding: buffer, as: UTF8.self)
                    })
                }
            }
        } else if addr.ss_family == sa_family_t(AF_INET6) { // IPv6
            return withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sa in
                    return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: Int(INET6_ADDRSTRLEN), { buffer in
                        var addr = sa.pointee.sin6_addr
                        inet_ntop(AF_INET6, &addr, buffer.baseAddress, socklen_t(INET6_ADDRSTRLEN))
                        return String(decoding: buffer, as: UTF8.self)
                    })
                }
            }
        }
        return nil
    }
}



// MARK: Receive
extension FileDescriptor {
    #if Inlinable
    @inlinable
    #endif
    public func socketReceive(_ baseAddress: UnsafeMutablePointer<UInt8>, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    #if Inlinable
    @inlinable
    #endif
    public func socketReceive(_ baseAddress: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Read
extension FileDescriptor {
    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
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
}

// MARK: Send
extension FileDescriptor {
    #if Inlinable
    @inlinable
    #endif
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
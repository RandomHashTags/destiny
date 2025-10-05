
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

import CustomOperators

// MARK: Int32
extension Int32 {
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
        let read = socketReceive(baseAddress: baseAddress, length: length, flags: flags)
        if read < 0 { // error
            try handleReadError()
        }
        return read
    }

    #if Inlinable
    @inlinable
    #endif
    package func handleReadError() throws(SocketError) {
        #if canImport(Glibc)
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #endif
        throw .readBufferFailed(errno: errno)
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
            let result = socketSendMultiplatform(pointer: pointer + sent, length: length -! sent)
            if result <= 0 {
                throw .writeFailed(errno: errno)
            }
            sent +=! result
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError) {
        let result = withUnsafeTemporaryAllocation(of: iovec.self, capacity: count) { iovecs in
            for i in buffers.indices {
                let buffer = buffers[unchecked: i]
                iovecs[i] = .init(iov_base: .init(mutating: buffer.baseAddress), iov_len: buffer.count)
            }
            return writev(fileDescriptor, iovecs.baseAddress, Int32(count))
        }
        if result <= 0 {
            throw .writeFailed(errno: errno)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, (buffer: UnsafePointer<UInt8>, bufferCount: Int)>
    ) throws(SocketError) {
        let result = withUnsafeTemporaryAllocation(of: iovec.self, capacity: count) { iovecs in
            for i in buffers.indices {
                let (buffer, bufferCount) = buffers[unchecked: i]
                iovecs[i] = .init(iov_base: .init(mutating: buffer), iov_len: bufferCount)
            }
            return writev(fileDescriptor, iovecs.baseAddress, Int32(count))
        }
        if result <= 0 {
            throw .writeFailed(errno: errno)
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
extension Int32 {
    #if Inlinable
    @inlinable
    #endif
    public func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    #if Inlinable
    @inlinable
    #endif
    public func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Send
extension Int32 {
    #if Inlinable
    @inlinable
    #endif
    public func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return send(fileDescriptor, pointer, length, Int32(MSG_NOSIGNAL))
        #else
        return write(self, pointer, length)
        #endif
    }
}


// MARK: Conformances
//#if Protocols

extension Int32: FileDescriptor {}

//#endif
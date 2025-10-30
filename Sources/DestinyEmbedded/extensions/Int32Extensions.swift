
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

// MARK: Int32
extension Int32 {
    public var fileDescriptor: Int32 {
        self
    }

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

    package func handleReadError() throws(SocketError) {
        #if canImport(Glibc)
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #endif
        throw .readBufferFailed(errno: errno)
    }

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

// MARK: Address
extension Int32 {
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
    public func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    public func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Send
extension Int32 {
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
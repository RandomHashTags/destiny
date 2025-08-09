
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

// MARK: Receive
extension Int32 {
    @inlinable
    public func socketReceive(_ baseAddress: UnsafeMutablePointer<UInt8>, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(self, baseAddress, length, flags)
    }
    @inlinable
    public func socketReceive(_ baseAddress: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(self, baseAddress, length, flags)
    }
}

// MARK: Write
extension Int32 {
    @inlinable
    public func socketWriteBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            if Task.isCancelled { return }
            let result = socketSendMultiplatform(pointer + sent, length - sent)
            if result <= 0 {
                throw SocketError.writeFailed()
            }
            sent += result
        }
    }

    @inlinable
    public func socketWriteBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws(SocketError) {
        var err:SocketError? = nil
        withUnsafeTemporaryAllocation(of: iovec.self, capacity: count, { iovecs in
            for i in buffers.indices {
                let buffer = buffers[i]
                iovecs[i] = .init(iov_base: .init(mutating: buffer.baseAddress), iov_len: buffer.count)
            }
            let result = writev(self, iovecs.baseAddress, Int32(count))
            if result <= 0 {
                err = SocketError.writeFailed()
            }
        })
        if let err {
            throw err
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
extension Int32 {
    @inlinable
    package func socketSendMultiplatform(_ pointer: UnsafeRawPointer, _ length: Int) -> Int {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return send(self, pointer, length, Int32(MSG_NOSIGNAL))
        #else
        return write(self, pointer, length)
        #endif
    }
}

// MARK: Close
extension Int32 {
    @inlinable
    package func socketClose() {
        #if canImport(SwiftGlibc) || canImport(Foundation)
        shutdown(self, Int32(SHUT_RDWR)) // shutdown read and write (https://www.gnu.org/software/libc/manual/html_node/Closing-a-Socket.html)
        close(self)
        #else
        #warning("Unable to shutdown and close file descriptor!")
        #endif
    }
}
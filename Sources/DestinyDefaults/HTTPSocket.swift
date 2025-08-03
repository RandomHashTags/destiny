
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

import DestinyBlueprint

/// Default socket storage with the only purpose of handling communication between http clients and the http server.
public struct HTTPSocket: HTTPSocketProtocol, ~Copyable {
    public typealias Buffer = InlineByteArray<1024>

    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    @inlinable
    public func loadRequest() throws -> Request {
        return try Request.load(socket: self)
    }
}

// MARK: Reading
extension HTTPSocket {
    @inlinable
    public func readBuffer() throws -> (Buffer, Int) {
        var buffer = Buffer.init(repeating: 0)
        let read = try withUnsafeMutableBytes(of: &buffer) { p in
            return try readBuffer(into: p.baseAddress!, length: Buffer.count)
        }
        return (buffer, read)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into buffer: UnsafeMutableBufferPointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        guard let baseAddress = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32 = 0) throws -> Int {
        var bytesRead = 0
        while bytesRead < length {
            if Task.isCancelled { return 0 }
            let toRead = min(Buffer.count, length - bytesRead)
            let read = receive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead += read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32 = 0) throws -> Int {
        var bytesRead = 0
        while bytesRead < length {
            if Task.isCancelled { return 0 }
            let toRead = min(Buffer.count, length - bytesRead)
            let read = receive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead += read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer.
    /// 
    /// - Returns: The number of bytes received.
    @inlinable
    public func readBuffer(into baseAddress: UnsafeMutableRawPointer, length: Int) throws -> Int {
        if Task.isCancelled { return 0 }
        let read = receive(baseAddress, length, 0)
        if read < 0 { // error
            try handleReadError()
        }
        return read
    }

    @inlinable
    public func handleReadError() throws {
        #if canImport(Glibc)
        if errno == EAGAIN || errno == EWOULDBLOCK {
            return
        }
        #endif
        throw SocketError.readBufferFailed()
    }
}

// MARK: Receive
extension HTTPSocket {
    @usableFromInline
    func receive(_ baseAddress: UnsafeMutablePointer<UInt8>, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
    @usableFromInline
    func receive(_ baseAddress: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        return recv(fileDescriptor, baseAddress, length, flags)
    }
}

// MARK: Writing
extension HTTPSocket {
    @inlinable
    public func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent = 0
        while sent < length {
            if Task.isCancelled { return }
            let result = sendMultiplatform(pointer + sent, length - sent)
            if result <= 0 {
                throw SocketError.writeFailed()
            }
            sent += result
        }
    }

    @inlinable
    public func writeBuffers<let count: Int>(
        _ buffers: InlineArray<count, UnsafeBufferPointer<UInt8>>
    ) throws {
        withUnsafeTemporaryAllocation(of: iovec.self, capacity: count, { iovecs in
            for i in buffers.indices {
                let buffer = buffers[i]
                iovecs[i] = .init(iov_base: .init(mutating: buffer.baseAddress), iov_len: buffer.count)
            }
            writev(fileDescriptor, iovecs.baseAddress, Int32(count))
        })
    }
}

// MARK: Send
extension HTTPSocket {
    @usableFromInline
    func sendMultiplatform(_ pointer: UnsafeRawPointer, _ length: Int) -> Int {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return send(fileDescriptor, pointer, length, Int32(MSG_NOSIGNAL))
        #else
        return write(fileDescriptor, pointer, length)
        #endif
    }
}
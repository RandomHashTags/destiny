
import UnwrapArithmeticOperators

/// Default HTTP Socket implementation.
public struct HTTPSocket: Sendable, ~Copyable {
    public typealias Buffer = InlineArray<1024, UInt8>

    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    public func socketLocalAddress() -> String? {
        fileDescriptor.socketLocalAddress()
    }

    public func socketPeerAddress() -> String? {
        fileDescriptor.socketPeerAddress()
    }
}

// MARK: Reading
extension HTTPSocket {
    /// Reads multiple bytes and writes them into a buffer
    public func readBuffer(
        into buffer: UnsafeMutableBufferPointer<UInt8>,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        guard let baseAddress = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    public func readBuffer(
        into baseAddress: UnsafeMutablePointer<UInt8>,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        var bytesRead = 0
        while bytesRead < length {
            let toRead = min(Buffer.count, length -! bytesRead)
            let read = fileDescriptor.socketReceive(baseAddress: baseAddress + bytesRead, length: toRead, flags: flags)
            if read < 0 { // error
                try fileDescriptor.handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead +=! read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer
    public func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        var bytesRead = 0
        while bytesRead < length {
            let toRead = min(Buffer.count, length -! bytesRead)
            let read = fileDescriptor.socketReceive(baseAddress: baseAddress + bytesRead, length: toRead, flags: flags)
            if read < 0 { // error
                try fileDescriptor.handleReadError()
                break
            } else if read == 0 { // end of file
                break
            }
            bytesRead +=! read
        }
        return bytesRead
    }

    /// Reads multiple bytes and writes them into a buffer.
    /// 
    /// - Returns: Number of bytes received.
    public func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int
    ) throws(SocketError) -> Int {
        return try fileDescriptor.readBuffer(into: baseAddress, length: length, flags: 0)
    }
}

// MARK: Writing
extension HTTPSocket {
    public func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            let result = socketSendMultiplatform(pointer: pointer + sent, length: length -! sent)
            if result <= 0 {
                throw .writeFailed(errno: cError())
            }
            sent +=! result
        }
    }

    public func writeBuffers3(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers3(b1, b2, b3)
    }

    public func writeBuffers4(
        _ b1: UnsafeBufferPointer<UInt8>,
        _ b2: UnsafeBufferPointer<UInt8>,
        _ b3: UnsafeBufferPointer<UInt8>,
        _ b4: UnsafeBufferPointer<UInt8>
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers4(b1, b2, b3, b4)
    }

    public func writeBuffers6(
        _ b1: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b2: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b3: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b4: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b5: (buffer: UnsafePointer<UInt8>, bufferCount: Int),
        _ b6: (buffer: UnsafePointer<UInt8>, bufferCount: Int)
    ) throws(SocketError) {
        try fileDescriptor.writeBuffers6(b1, b2, b3, b4, b5, b6)
    }
}

// MARK: Socket
extension HTTPSocket {
    public func socketReceive(baseAddress: UnsafeMutablePointer<UInt8>, length: Int, flags: Int32) -> Int {
        return fileDescriptor.socketReceive(baseAddress: baseAddress, length: length, flags: flags)
    }

    public func socketReceive(baseAddress: UnsafeMutableRawPointer, length: Int, flags: Int32) -> Int {
        return fileDescriptor.socketReceive(baseAddress: baseAddress, length: length, flags: flags)
    }

    public func socketSendMultiplatform(pointer: UnsafeRawPointer, length: Int) -> Int {
        return fileDescriptor.socketSendMultiplatform(pointer: pointer, length: length)
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension HTTPSocket: FileDescriptor {}

#endif
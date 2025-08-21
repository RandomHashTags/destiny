
import DestinyBlueprint

/// Default HTTP Socket implementation.
public struct HTTPSocket: HTTPSocketProtocol, ~Copyable {
    public typealias Buffer = InlineByteArray<1024>

    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    @inlinable
    public func loadRequest() -> Request {
        return Request(fileDescriptor: fileDescriptor)
    }
}

// MARK: Reading
extension HTTPSocket {
    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(
        into buffer: UnsafeMutableBufferPointer<UInt8>,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        guard let baseAddress = buffer.baseAddress else { return 0 }
        return try readBuffer(into: baseAddress, length: length, flags: flags)
    }

    /// Reads multiple bytes and writes them into a buffer
    @inlinable
    public func readBuffer(
        into baseAddress: UnsafeMutablePointer<UInt8>,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        var bytesRead = 0
        while bytesRead < length {
            let toRead = min(Buffer.count, length - bytesRead)
            let read = fileDescriptor.socketReceive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try fileDescriptor.handleReadError()
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
    public func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int,
        flags: Int32 = 0
    ) throws(SocketError) -> Int {
        var bytesRead = 0
        while bytesRead < length {
            let toRead = min(Buffer.count, length - bytesRead)
            let read = fileDescriptor.socketReceive(baseAddress + bytesRead, toRead, flags)
            if read < 0 { // error
                try fileDescriptor.handleReadError()
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
    public func readBuffer(
        into baseAddress: UnsafeMutableRawPointer,
        length: Int
    ) throws(SocketError) -> Int {
        return try fileDescriptor.socketReadBuffer(into: baseAddress, length: length, flags: 0)
    }
}

// MARK: Writing
extension HTTPSocket {
    @inlinable
    public func writeBuffer(
        _ pointer: UnsafeRawPointer,
        length: Int
    ) throws(SocketError) {
        var sent = 0
        while sent < length {
            let result = sendMultiplatform(pointer + sent, length - sent)
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
        try fileDescriptor.socketWriteBuffers(buffers)
    }
}

// MARK: Send
extension HTTPSocket {
    @usableFromInline
    func sendMultiplatform(_ pointer: UnsafeRawPointer, _ length: Int) -> Int {
        return fileDescriptor.socketSendMultiplatform(pointer, length)
    }
}
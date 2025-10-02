
import DestinyBlueprint

public struct AsyncHTTPChunkDataStream<T: HTTPChunkDataProtocol> {
    public let chunkSize:Int
    public let stream:ReusableAsyncStream<T>

    public init(
        chunkSize: Int = 1024,
        _ values: some Sequence<T> & Sendable
    ) {
        self.chunkSize = chunkSize
        stream = ReusableAsyncStream {
            AsyncStream { continuation in
                for value in values {
                    continuation.yield(value)
                }
                continuation.finish()
            }
        }
    }

    public init(
        chunkSize: Int = 1024,
        _ stream: ReusableAsyncStream<T>
    ) {
        self.chunkSize = chunkSize
        self.stream = stream
    }
    public init(
        chunkSize: Int = 1024,
        _ stream: AsyncStream<T>
    ) {
        self.chunkSize = chunkSize
        self.stream = ReusableAsyncStream { stream }
    }
}

// MARK: Write
extension AsyncHTTPChunkDataStream {
    #if Inlinable
    @inlinable
    #endif
    public func write(
        to socket: some FileDescriptor
    ) async throws(SocketError) {
        // 20 = length in hexadecimal (16) + "\r\n".count * 2 (4)
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 20 + chunkSize)
        buffer.initialize(repeating: 0)
        defer {
            buffer.deallocate()
        }
        for await var chunk in stream {
            var i = 0
            var hex = String(chunk.chunkDataCount, radix: 16)
            hex.withUTF8 {
                for byte in $0 {
                    buffer[i] = byte
                    i += 1
                }
            }
            buffer[i] = .carriageReturn
            i += 1
            buffer[i] = .lineFeed
            i += 1

            do throws(BufferWriteError) {
                try chunk.write(to: buffer, at: &i)
            } catch {
                throw SocketError.bufferWriteError(error)
            }

            buffer[i] = .carriageReturn
            i += 1
            buffer[i] = .lineFeed
            i += 1
            try socket.socketWriteBuffer(buffer.baseAddress!, length: i)
        }
        buffer[0] = 48
        buffer[1] = .carriageReturn
        buffer[2] = .lineFeed
        buffer[3] = .carriageReturn
        buffer[4] = .lineFeed
        try socket.socketWriteBuffer(buffer.baseAddress!, length: 5)
    }
}

// MARK: Conformances
extension AsyncHTTPChunkDataStream: AsyncHTTPSocketWritable {}
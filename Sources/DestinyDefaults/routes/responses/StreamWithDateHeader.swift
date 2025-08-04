
import DestinyBlueprint

public struct StreamWithDateHeader<Body: HTTPSocketWritable>: StaticRouteResponderProtocol {
    public let head:StaticString
    public let body:Body

    public init(_ head: StaticString, body: Body) {
        self.head = head
        self.body = body
    }
}

// MARK: Write
extension StreamWithDateHeader {
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        var err:SocketError? = nil
        head.withUTF8Buffer { headPointer in
            // 30 = "Transfer-Encoding: chunked".count (26) + "\r\n\r\n".count (4)
             withUnsafeTemporaryAllocation(of: UInt8.self, capacity: headPointer.count + 30, { buffer in
                var i = 0
                buffer.copyBuffer(headPointer, at: &i)
                // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                var offset = 20
                let dateSpan = HTTPDateFormat.nowInlineArray
                for indice in dateSpan.indices {
                    buffer[offset] = dateSpan[indice]
                    offset += 1
                }
                let transferEncodingChunked:InlineArray<26, UInt8> = [84, 114, 97, 110, 115, 102, 101, 114, 45, 69, 110, 99, 111, 100, 105, 110, 103, 58, 32, 99, 104, 117, 110, 107, 101, 100] // Transfer-Encoding: chunked
                for indice in transferEncodingChunked.indices {
                    buffer[i] = transferEncodingChunked[indice]
                    i += 1
                }
                buffer[i] = .carriageReturn
                i += 1
                buffer[i] = .lineFeed
                i += 1
                buffer[i] = .carriageReturn
                i += 1
                buffer[i] = .lineFeed
                do throws(SocketError) {
                    try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                } catch {
                    err = error
                }
            })
        }
        if let err {
            throw err
        }
        try await body.write(to: socket)
    }
}

// MARK: AsyncHTTPChunkDataStream
public struct AsyncHTTPChunkDataStream<T: HTTPChunkDataProtocol>: HTTPSocketWritable {
    public let chunkSize:Int
    public let stream:ReusableAsyncThrowingStream<T, Error> // TODO: fix

    public init(
        chunkSize: Int = 1024,
        _ values: some Sequence<T>
    ) {
        self.chunkSize = chunkSize
        stream = ReusableAsyncThrowingStream {
            AsyncThrowingStream { continuation in
                for value in values {
                    continuation.yield(value)
                }
                continuation.finish()
            }
        }
    }

    public init(
        chunkSize: Int = 1024,
        _ stream: ReusableAsyncThrowingStream<T, Error>
    ) {
        self.chunkSize = chunkSize
        self.stream = stream
    }
    public init(
        chunkSize: Int = 1024,
        _ stream: AsyncThrowingStream<T, Error>
    ) {
        self.chunkSize = chunkSize
        self.stream = ReusableAsyncThrowingStream { stream }
    }

    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        // 20 = length in hexadecimal (16) + "\r\n".count * 2 (4)
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 20 + chunkSize)
        buffer.initialize(repeating: 0)
        var err:SocketError? = nil
        do throws(Error) { // TODO: fix
            for try await var chunk in stream {
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
                try socket.writeBuffer(buffer.baseAddress!, length: i)
            }
            do throws(SocketError) {
                buffer[0] = 48
                buffer[1] = .carriageReturn
                buffer[2] = .lineFeed
                buffer[3] = .carriageReturn
                buffer[4] = .lineFeed
                try socket.writeBuffer(buffer.baseAddress!, length: 5)
            } catch {
                print("AsyncHTTPChunkDataStream;\(#function);error trying to send final chunk to stream") // TODO: use logger
                err = error
            }
        } catch {
            err = .init(identifier: "streamWithDateHeaderWriteError", reason: "\(error)")
        }
        buffer.deallocate()
        if let err {
            throw err
        }
    }
}
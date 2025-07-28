
import DestinyBlueprint

public struct StreamWithDateHeader<Body: HTTPSocketWritable>: StaticRouteResponderProtocol {
    public let head:String
    public let body:Body

    public init(_ head: String, body: Body) {
        self.head = head
        self.body = body
    }
}

// MARK: Write
extension StreamWithDateHeader {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try head.utf8.withContiguousStorageIfAvailable { headPointer in
            try HTTPDateFormat.shared.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                // 30 = "Transfer-Encoding: chunked".count (26) + "\r\n\r\n".count (4)
                try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: headPointer.count + 30, { buffer in
                    var i = 0
                    buffer.copyBuffer(headPointer, at: &i)
                    // 20 = "HTTP/<v> <c>\r\n".count + "Date: ".count (14 + 6) where `<v>` is the HTTP Version and `<c>` is the HTTP Status Code
                    var offset = 20
                    for i in 0..<HTTPDateFormat.InlineArrayResult.count {
                        buffer[offset] = datePointer[i]
                        offset += 1
                    }
                    let transferEncoding:InlineArray<26, UInt8> = #inlineArray("Transfer-Encoding: chunked")
                    for indice in transferEncoding.indices {
                        buffer[i] = transferEncoding[indice]
                        i += 1
                    }
                    buffer[i] = .carriageReturn
                    i += 1
                    buffer[i] = .lineFeed
                    i += 1
                    buffer[i] = .carriageReturn
                    i += 1
                    buffer[i] = .lineFeed
                    try socket.writeBuffer(buffer.baseAddress!, length: buffer.count)
                })
            }
        }
        try await body.write(to: socket)
    }
}

// MARK: AsyncHTTPChunkDataStream
public struct AsyncHTTPChunkDataStream<T: HTTPChunkDataProtocol>: HTTPSocketWritable {
    public let chunkSize:Int
    public let stream:ReusableAsyncThrowingStream<T, Error>

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
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        // 20 = length in hexadecimal (16) + "\r\n".count * 2 (4)
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 20 + chunkSize)
        buffer.initialize(repeating: 0)
        var err:Error? = nil
        do {
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
                try chunk.write(to: buffer, at: &i)
                buffer[i] = .carriageReturn
                i += 1
                buffer[i] = .lineFeed
                i += 1
                try socket.writeBuffer(buffer.baseAddress!, length: i)
            }
            do {
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
            err = error
        }
        buffer.deallocate()
        if let err {
            throw err
        }
    }
}
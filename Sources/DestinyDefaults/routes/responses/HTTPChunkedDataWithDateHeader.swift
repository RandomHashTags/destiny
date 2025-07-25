
import DestinyBlueprint

public struct HTTPChunkedDataWithDateHeader<Body: HTTPSocketWritable>: StaticRouteResponderProtocol {
    public let head:String
    public let body:Body

    public init(_ head: String, body: Body) {
        self.head = head
        self.body = body
    }
}

// MARK: Write
extension HTTPChunkedDataWithDateHeader {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
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

    public init<S: Sequence<T>>(
        chunkSize: Int = 1024,
        _ values: S
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
        self.stream = ReusableAsyncThrowingStream {
            stream
        }
    }

    @inlinable
    public func write<Socket: HTTPSocketProtocol & ~Copyable>(to socket: borrowing Socket) async throws {
        // 20 = length in hexadecimal (16) + "\r\n".count * 2 (4)
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 20 + chunkSize)
        buffer.initialize(repeating: 0)
        do {
            for try await var v in stream {
                var i = 0
                var hex = String(v.chunkDataCount, radix: 16)
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
                try v.write(to: buffer, at: &i)
                buffer[i] = .carriageReturn
                i += 1
                buffer[i] = .lineFeed
                i += 1
                try socket.writeBuffer(buffer.baseAddress!, length: i)
            }
            buffer[0] = 48
            buffer[1] = .carriageReturn
            buffer[2] = .lineFeed
            buffer[3] = .carriageReturn
            buffer[4] = .lineFeed
            try socket.writeBuffer(buffer.baseAddress!, length: 5)
            buffer.deallocate()
        } catch {
            buffer.deallocate()
            throw error
        }
    }
}
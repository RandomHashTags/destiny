
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
public struct AsyncHTTPChunkDataStream<T: HTTPSocketWritable>: HTTPSocketWritable {
    public let stream:AsyncStream<T>

    public init<S: Sequence<T>>(
        _ values: S
    ) {
        stream = AsyncStream { continuation in
            for value in values {
                continuation.yield(value)
            }
            continuation.finish()
        }
    }

    @inlinable
    public func write<Socket: HTTPSocketProtocol & ~Copyable>(to socket: borrowing Socket) async throws {
        for await v in stream {
            try await v.write(to: socket)
        }
    }
}
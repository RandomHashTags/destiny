
import DestinyBlueprint

public struct RequestBody<FD: FileDescriptor>: Sendable, ~Copyable {
    public typealias Buffer = InlineArray<16_384, UInt8> // 16 KB

    @usableFromInline
    let fileDescriptor:FD

    @usableFromInline
    var _totalRead = 0

    package init(
        fileDescriptor: FD,
        totalRead: Int = 0
    ) {
        self.fileDescriptor = fileDescriptor
        self._totalRead = totalRead
    }

    #if Inlinable
    @inlinable
    #endif
    public var totalRead: Int {
        _totalRead
    }
}


// MARK: Stream, default size
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func stream(
        //maximumSize: Int = 500_000,
        _ yield: (Buffer) async throws -> Void
    ) async throws {
        var buffer = Buffer(repeating: 0)
        try await stream(buffer: &buffer, yield)
    }
}

// MARK: Stream, custom size
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        //maximumSize: Int = 500_000,
        _ yield: (InlineArray<chunkSize, UInt8>) async throws -> Void
    ) async throws {
        var buffer = InlineArray<chunkSize, UInt8>(repeating: 0)
        try await stream(buffer: &buffer, yield)
    }
}

// MARK: Stream
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        buffer: inout InlineArray<chunkSize, UInt8>,
        _ yield: (InlineArray<chunkSize, UInt8>) async throws -> Void
    ) async throws {
        let asyncStream = AsyncThrowingStream<InlineArray<chunkSize, UInt8>, Error> { continuation in
            var err:SocketError? = nil
            while true {
                var read = 0
                var mutableSpan = buffer.mutableSpan
                mutableSpan.withUnsafeMutableBufferPointer { p in
                    do throws(SocketError) {
                        guard let base = p.baseAddress else {
                            throw SocketError.readBufferFailed("baseAddress == nil")
                        }
                        read = try fileDescriptor.readBuffer(into: base, length: chunkSize, flags: 0)
                    } catch {
                        err = error
                    }
                }
                if let err {
                    continuation.finish(throwing: err)
                    break
                }
                if read <= 0 {
                    continuation.finish(throwing: SocketError.readBufferFailed())
                    break
                }
                _totalRead += read
                if read != chunkSize {
                    for i in stride(from: chunkSize-1, to: read-1, by: -1) {
                        mutableSpan[i] = 0
                    }
                    continuation.yield(buffer)
                    continuation.finish()
                    break
                } else {
                    continuation.yield(buffer)
                }
            }
        }
        for try await b in asyncStream {
            try await yield(b)
        }
    }
}

// MARK: YieldResult
extension RequestBody {
    // TODO: can't yet use this: https://github.com/swiftlang/swift/issues/84141
    public enum StreamYieldResult<let count: Int>: Sendable {
        case literal(buffer: InlineArray<count, UInt8>)
        case end(buffer: InlineArray<count, UInt8>, endIndex: Int)

        /*#if Inlinable
        @inlinable
        #endif
        #if InlineAlways
        @inline(__always)
        #endif
        public var buffer: InlineArray<count, UInt8> {
            switch self {
            case .literal(let b):
                return b
            case .end(let b, _):
                return b
            }
        }*/
    }
}
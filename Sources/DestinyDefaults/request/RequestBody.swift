
import DestinyBlueprint

public struct RequestBody<FD: FileDescriptor>: Sendable, ~Copyable {
    public typealias Buffer = InlineArray<16_384, UInt8> // 16 KB

    @usableFromInline
    let fileDescriptor:FD

    @usableFromInline
    var _totalRead:UInt64

    #if Inlinable
    @inlinable
    #endif
    package init(
        fileDescriptor: FD,
        totalRead: UInt64 = 0
    ) {
        self.fileDescriptor = fileDescriptor
        self._totalRead = totalRead
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var totalRead: UInt64 {
        _totalRead
    }
}

// MARK: Read
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func read<let count: Int>(
        into buffer: inout InlineArray<count, UInt8>
    ) throws(SocketError) -> Int {
        var err:SocketError? = nil
        var read = 0
        var mutableSpan = buffer.mutableSpan
        mutableSpan.withUnsafeMutableBufferPointer { p in
            guard let base = p.baseAddress else {
                err = .readBufferFailed("baseAddress == nil")
                return
            }
            do throws(SocketError) {
                read = try fileDescriptor.readBuffer(into: base, length: count, flags: 0)
                if read <= 0 {
                    err = .readBufferFailed()
                }
            } catch {
                err = error
            }
        }
        if let err {
            throw err
        }
        _totalRead += UInt64(read)
        return read
    }
}

// MARK: Collect
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func collect() throws(SocketError) -> (buffer: Buffer, read: Int) {
        var buffer = Buffer(repeating: 0)
        let read = try read(into: &buffer)
        return (buffer, read)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func collect<let count: Int>() throws(SocketError) -> (buffer: InlineArray<count, UInt8>, read: Int) {
        var buffer = InlineArray<count, UInt8>(repeating: 0)
        let read = try read(into: &buffer)
        return (buffer, read)
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
            while true {
                var read = 0
                do throws(SocketError) {
                    read = try self.read(into: &buffer)
                } catch {
                    continuation.finish(throwing: error)
                    break
                }
                if read != chunkSize {
                    for i in stride(from: chunkSize-1, to: read-1, by: -1) {
                        buffer[i] = 0
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
    enum StreamYieldResult<let count: Int>: Sendable {
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
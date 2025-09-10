
import DestinyBlueprint

public struct RequestBody: Sendable, ~Copyable {
    @usableFromInline
    var _totalRead:UInt64

    #if Inlinable
    @inlinable
    #endif
    package init(
        totalRead: UInt64 = 0
    ) {
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
        fileDescriptor: some FileDescriptor,
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
    public mutating func collect<let count: Int>(
        fileDescriptor: some FileDescriptor
    ) throws(SocketError) -> InlineByteBuffer<count> {
        var buffer = InlineArray<count, UInt8>(repeating: 0)
        let read = try read(fileDescriptor: fileDescriptor, into: &buffer)
        return .init(buffer: buffer, endIndex: read)
    }
}

// MARK: Stream
extension RequestBody {
    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        fileDescriptor: some FileDescriptor,
        //maximumSize: Int = 500_000,
        _ yield: (consuming InlineByteBuffer<chunkSize>) async throws -> Void
    ) async throws {
        var buffer = InlineArray<chunkSize, UInt8>(repeating: 0)
        try await stream(fileDescriptor: fileDescriptor,buffer: &buffer, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func stream<let chunkSize: Int>(
        fileDescriptor: some FileDescriptor,
        buffer: inout InlineArray<chunkSize, UInt8>,
        _ yield: (consuming InlineByteBuffer<chunkSize>) async throws -> Void
    ) async throws {
        let asyncStream = AsyncThrowingStream<CopyableInlineBuffer<chunkSize>, Error> { continuation in
            while true {
                var read = 0
                do throws(SocketError) {
                    read = try self.read(fileDescriptor: fileDescriptor, into: &buffer)
                } catch {
                    continuation.finish(throwing: error)
                    break
                }
                if read != chunkSize {
                    for i in stride(from: chunkSize-1, to: read-1, by: -1) {
                        buffer[i] = 0
                    }
                    continuation.yield(.init(buffer: buffer, endIndex: read))
                    continuation.finish()
                    break
                } else {
                    continuation.yield(.init(buffer: buffer, endIndex: read))
                }
            }
        }
        for try await b in asyncStream {
            try await yield(b.noncopyable())
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
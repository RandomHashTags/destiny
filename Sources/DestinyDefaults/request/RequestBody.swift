
#if RequestBody

import DestinyBlueprint

public struct RequestBody: Sendable, ~Copyable {
    @usableFromInline
    package var _totalRead:UInt64

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
    package mutating func read<let count: Int>(
        fileDescriptor: some FileDescriptor,
        into buffer: inout InlineArray<count, UInt8>
    ) throws(SocketError) -> Int {
        var err:SocketError? = nil
        var read = 0
        var mutableSpan = buffer.mutableSpan
        mutableSpan.withUnsafeMutableBufferPointer { p in
            guard let base = p.baseAddress else {
                err = .custom("readBufferFailed;baseAddress == nil")
                return
            }
            do throws(SocketError) {
                read = try fileDescriptor.readBuffer(into: base, length: count, flags: 0)
                if read <= 0 {
                    err = .readBufferFailed(errno: cError())
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

#endif
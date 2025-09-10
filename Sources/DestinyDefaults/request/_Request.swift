
import DestinyBlueprint

/// Universal request storage that works for different `FileDescriptor` implementations.
@usableFromInline
struct _Request<let initalBufferCount: Int>: Sendable, ~Copyable {

    @usableFromInline
    var _storage:Request._Storage

    @usableFromInline
    var initialBuffer:InlineByteBuffer<initalBufferCount>? = nil

    @usableFromInline
    var storage:Request.Storage

    @inlinable
    @inline(__always)
    init(
        _storage: consuming Request._Storage = .init(),
        storage: consuming Request.Storage = .init([:])
    ) {
        self._storage = _storage
        self.storage = storage
    }

    @inlinable
    @inline(__always)
    mutating func headers(fileDescriptor: some FileDescriptor) throws(SocketError) -> [Substring:Substring] {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        if _storage._headers!._endIndex == nil {
            _storage._headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
        }
        return _storage._headers!.headers
    }
}

// MARK: Protocol conformance
extension _Request {
    @inlinable
    @inline(__always)
    mutating func forEachPath(
        fileDescriptor: some FileDescriptor,
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        let path = _storage.path(buffer: initialBuffer!)
        var i = offset
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    @inlinable
    @inline(__always)
    mutating func path(fileDescriptor: some FileDescriptor, at index: Int) throws(SocketError) -> String {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return _storage.path(buffer: initialBuffer!)[index]
    }

    @inlinable
    @inline(__always)
    mutating func pathCount(fileDescriptor: some FileDescriptor) throws(SocketError) -> Int {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return _storage.path(buffer: initialBuffer!).count
    }

    @inlinable
    @inline(__always)
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == _storage.methodString(buffer: initialBuffer!)
    }

    @inlinable
    @inline(__always)
    mutating func header(fileDescriptor: some FileDescriptor, forKey key: String) throws(SocketError) -> String? {
        guard let value = try headers(fileDescriptor: fileDescriptor)[Substring(key)] else { return nil }
        return String(value)
    }

    @inlinable
    @inline(__always)
    func copy() -> Self {
        var c = Self()
        c._storage = _storage.copy()
        c.initialBuffer = initialBuffer?.copy()
        c.storage = storage.copy()
        return c
    }
}

// MARK: Load
extension _Request {
    @inlinable
    @inline(__always)
    static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> Self {
        Self()
    }
}

// MARK: Load storage
extension _Request {
    /// Loads `initialBuffer` and `_storage`.
    @inlinable
    @inline(__always)
    mutating func loadStorage(fileDescriptor: some FileDescriptor) throws(SocketError) {
        let initialBuffer:InlineByteBuffer<initalBufferCount> = try readBuffer(fileDescriptor: fileDescriptor)
        if initialBuffer.endIndex <= 0 {
            throw .malformedRequest()
        }
        try _storage.load(
            buffer: initialBuffer
        )
        self.initialBuffer = consume initialBuffer
    }
}

// MARK: Read buffer
extension _Request {
    /// - Warning: **DOESN'T** check if the read bytes are >= 0!
    @inlinable
    @inline(__always)
    func readBuffer<let count: Int>(fileDescriptor: some FileDescriptor) throws(SocketError) -> InlineByteBuffer<count> {
        var buffer = InlineArray<count, UInt8>(repeating: 0)
        var mutableSpan = buffer.mutableSpan
        var err:SocketError? = nil
        let read = mutableSpan.withUnsafeMutableBufferPointer { p in
            do throws(SocketError) {
                return try fileDescriptor.readBuffer(into: p.baseAddress!, length: count, flags: 0)
            } catch {
                err = error
                return -1
            }
        }
        if let err {
            throw err
        }
        return .init(buffer: buffer, endIndex: read)
    }
}

// MARK: Start line
extension _Request {
    @inlinable
    @inline(__always)
    mutating func startLine(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return _storage.startLineSIMD(buffer: initialBuffer!)
    }

    @inlinable
    @inline(__always)
    mutating func startLineLowercased(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return _storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

// MARK: Body
extension _Request {
    @inlinable
    @inline(__always)
    mutating func bodyCollect<let count: Int>(fileDescriptor: some FileDescriptor) throws -> InlineByteBuffer<count> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return try _storage.bodyCollect(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
    }

    @inlinable
    @inline(__always)
    mutating func bodyStream<let count: Int>(
        fileDescriptor: some FileDescriptor,
        _ yield: (consuming InlineByteBuffer<count>) async throws -> Void
    ) async throws {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        try await _storage.bodyStream(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!, yield)
    }
}
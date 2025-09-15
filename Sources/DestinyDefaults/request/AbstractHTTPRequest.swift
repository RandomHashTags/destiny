
import DestinyBlueprint

/// Shared request storage that works for different `FileDescriptor` implementations.
@usableFromInline
struct AbstractHTTPRequest<let initalBufferCount: Int>: Sendable, ~Copyable {

    @usableFromInline
    var storage:_Storage

    @usableFromInline
    var initialBuffer:InlineByteBuffer<initalBufferCount>? = nil

    @usableFromInline
    var customStorage:HTTPRequest.Storage

    @inlinable
    @inline(__always)
    init(
        _storage: consuming _Storage = .init(),
        storage: consuming HTTPRequest.Storage = .init([:])
    ) {
        self.storage = _storage
        self.customStorage = storage
    }

    @inlinable
    @inline(__always)
    mutating func headers(fileDescriptor: some FileDescriptor) throws(SocketError) -> [Substring:Substring] {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        if storage._headers!._endIndex == nil {
            storage._headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
        }
        return storage._headers!.headers
    }
}

// MARK: Protocol conformance
extension AbstractHTTPRequest {
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
        let path = storage.path(buffer: initialBuffer!)
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
        return storage.path(buffer: initialBuffer!)[index]
    }

    @inlinable
    @inline(__always)
    mutating func pathCount(fileDescriptor: some FileDescriptor) throws(SocketError) -> Int {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!).count
    }

    @inlinable
    @inline(__always)
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
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
        c.storage = storage.copy()
        c.initialBuffer = initialBuffer?.copy()
        c.customStorage = customStorage.copy()
        return c
    }
}

// MARK: Load
extension AbstractHTTPRequest {
    @inlinable
    @inline(__always)
    static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> Self {
        Self()
    }
}

// MARK: Load storage
extension AbstractHTTPRequest {
    /// Loads `initialBuffer` and `_storage`.
    @inlinable
    @inline(__always)
    mutating func loadStorage(fileDescriptor: some FileDescriptor) throws(SocketError) {
        let initialBuffer:InlineByteBuffer<initalBufferCount> = try readBuffer(fileDescriptor: fileDescriptor)
        if initialBuffer.endIndex <= 0 {
            throw .malformedRequest()
        }
        try storage.load(
            buffer: initialBuffer
        )
        self.initialBuffer = consume initialBuffer
    }
}

// MARK: Read buffer
extension AbstractHTTPRequest {
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
extension AbstractHTTPRequest {
    @inlinable
    @inline(__always)
    mutating func startLine(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMD(buffer: initialBuffer!)
    }

    @inlinable
    @inline(__always)
    mutating func startLineLowercased(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

// MARK: Body
extension AbstractHTTPRequest {
    @inlinable
    @inline(__always)
    mutating func bodyCollect<let count: Int>(fileDescriptor: some FileDescriptor) throws -> InlineByteBuffer<count> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return try storage.bodyCollect(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
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
        try await storage.bodyStream(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!, yield)
    }
}
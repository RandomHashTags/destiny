
import DestinyBlueprint

/// Shared request storage that works for different `FileDescriptor` implementations.
@usableFromInline
package struct AbstractHTTPRequest<let initalBufferCount: Int>: Sendable, ~Copyable {

    @usableFromInline
    package var storage:_Storage

    @usableFromInline
    package var initialBuffer:InlineByteBuffer<initalBufferCount>? = nil

    @usableFromInline
    package var customStorage:HTTPRequest.Storage

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    init(
        _storage: consuming _Storage = .init(),
        storage: consuming HTTPRequest.Storage = .init([:])
    ) {
        self.storage = _storage
        self.customStorage = storage
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
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
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
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

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func path(fileDescriptor: some FileDescriptor, at index: Int) throws(SocketError) -> String {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!)[index]
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func pathCount(fileDescriptor: some FileDescriptor) throws(SocketError) -> Int {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!).count
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func header(fileDescriptor: some FileDescriptor, forKey key: String) throws(SocketError) -> String? {
        guard let value = try headers(fileDescriptor: fileDescriptor)[Substring(key)] else { return nil }
        return String(value)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
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
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> Self {
        Self()
    }
}

// MARK: Load storage
extension AbstractHTTPRequest {
    /// Loads `initialBuffer` and `_storage`.
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func loadStorage(fileDescriptor: some FileDescriptor) throws(SocketError) {
        let initialBuffer:InlineByteBuffer<initalBufferCount> = try readBuffer(fileDescriptor: fileDescriptor)
        if initialBuffer.endIndex <= 0 {
            throw .malformedRequest(errno: cError())
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
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
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
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func startLine(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMD(buffer: initialBuffer!)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func startLineLowercased(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

// MARK: Body
extension AbstractHTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func bodyCollect<let count: Int>(fileDescriptor: some FileDescriptor) throws(SocketError) -> InlineByteBuffer<count> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return try storage.bodyCollect(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
    }
}

import UnwrapArithmeticOperators

/// Shared request storage that works for different `FileDescriptor` implementations.
@usableFromInline
package struct AbstractHTTPRequest<let initalBufferCount: Int>: Sendable, ~Copyable {

    @usableFromInline
    package var storage:_Storage

    @usableFromInline
    package var initialBuffer:InlineByteBuffer<initalBufferCount>? = nil

    @usableFromInline
    package var customStorage:HTTPRequest.Storage

    init(
        _storage: consuming _Storage = .init(),
        storage: consuming HTTPRequest.Storage = .init([:])
    ) {
        self.storage = _storage
        self.customStorage = storage
    }

    /// Loads the headers from a buffer (if not already loaded).
    /// 
    /// - Returns: An efficient, case-sensitive dictionary of the headers.
    /// - Throws: `SocketError`
    mutating func headers(fileDescriptor: some FileDescriptor) throws(SocketError) -> [Substring:Substring] {
        #if RequestHeaders
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        if storage._headers!._endIndex == nil {
            storage._headers!.load(buffer: initialBuffer!)
        }
        return storage._headers!.headers
        #else
        return [:]
        #endif
    }
}

// MARK: Generic logic
extension AbstractHTTPRequest {
    /// - Throws: `SocketError`
    mutating func forEachPath(
        fileDescriptor: some FileDescriptor,
        offset: Int,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        let path = storage.path(buffer: initialBuffer!)
        var i = offset
        while i < path.count {
            yield(path[i])
            i +=! 1
        }
    }

    /// - Throws: `SocketError`
    mutating func path(fileDescriptor: some FileDescriptor, at index: Int) throws(SocketError) -> String {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!)[index]
    }

    /// - Throws: `SocketError`
    mutating func pathCount(fileDescriptor: some FileDescriptor) throws(SocketError) -> Int {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!).count
    }

    /// - Throws: `SocketError`
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: HTTPRequestMethod) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }

    /// - Throws: `SocketError`
    mutating func header(fileDescriptor: some FileDescriptor, forKey key: String) throws(SocketError) -> String? {
        #if RequestHeaders
        guard let value = try headers(fileDescriptor: fileDescriptor)[Substring(key)] else { return nil }
        return String(value)
        #else
        return nil
        #endif
    }

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
    static func load(from socket: consuming some FileDescriptor & ~Copyable) -> Self {
        Self()
    }
}

// MARK: Load storage
extension AbstractHTTPRequest {
    /// Loads `initialBuffer` and `_storage`.
    /// 
    /// - Throws: `SocketError`
    package mutating func loadStorage(fileDescriptor: some FileDescriptor) throws(SocketError) {
        let initialBuffer:InlineByteBuffer<initalBufferCount> = try readBuffer(fileDescriptor: fileDescriptor)
        if initialBuffer.endIndex == 0 { // socket was closed
            fileDescriptor.socketClose()
            throw .readZero
        } else if initialBuffer.endIndex < 0 {
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
    /// - Throws: `SocketError`
    /// - Warning: **DOESN'T** check if the read bytes are >= 0!
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
    /// - Throws: `SocketError`
    mutating func startLine(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMD(buffer: initialBuffer!)
    }

    /// - Throws: `SocketError`
    mutating func startLineLowercased(fileDescriptor: some FileDescriptor) throws(SocketError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

#if RequestBody

// MARK: Body
extension AbstractHTTPRequest {
    /// - Throws: `SocketError`
    mutating func bodyCollect<let count: Int>(fileDescriptor: some FileDescriptor) throws(SocketError) -> InlineByteBuffer<count> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return try storage.bodyCollect(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer!)
    }
}

#endif

#if Protocols

// MARK: Conformances
extension AbstractHTTPRequest {
    /// - Throws: `SocketError`
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }
}

#endif

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
    /// - Throws: `DestinyError`
    mutating func headers(fileDescriptor: some FileDescriptor) throws(DestinyError) -> [Substring:Substring] {
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
    /// - Throws: `DestinyError`
    mutating func forEachPath(
        fileDescriptor: some FileDescriptor,
        offset: Int,
        _ yield: (String) -> Void
    ) throws(DestinyError) {
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

    /// - Throws: `DestinyError`
    mutating func path(fileDescriptor: some FileDescriptor, at index: Int) throws(DestinyError) -> String {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!)[index]
    }

    /// - Throws: `DestinyError`
    mutating func pathCount(fileDescriptor: some FileDescriptor) throws(DestinyError) -> Int {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.path(buffer: initialBuffer!).count
    }

    /// - Throws: `DestinyError`
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: HTTPRequestMethod) throws(DestinyError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }

    /// - Throws: `DestinyError`
    mutating func header(fileDescriptor: some FileDescriptor, forKey key: String) throws(DestinyError) -> String? {
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
    /// - Throws: `DestinyError`
    package mutating func loadStorage(fileDescriptor: some FileDescriptor) throws(DestinyError) {
        let initialBuffer:InlineByteBuffer<initalBufferCount> = try readBuffer(fileDescriptor: fileDescriptor)
        if initialBuffer.endIndex == 0 { // socket was closed
            fileDescriptor.socketClose()
            throw .socketReadZero
        } else if initialBuffer.endIndex < 0 {
            throw .socketMalformedRequest(cError())
        }
        try storage.load(
            buffer: initialBuffer
        )
        self.initialBuffer = consume initialBuffer
    }
}

// MARK: Read buffer
extension AbstractHTTPRequest {
    /// - Throws: `DestinyError`
    /// - Warning: **DOESN'T** check if the read bytes are >= 0!
    func readBuffer<let count: Int>(fileDescriptor: some FileDescriptor) throws(DestinyError) -> InlineByteBuffer<count> {
        var buffer = InlineArray<count, UInt8>(repeating: 0)
        var mutableSpan = buffer.mutableSpan
        var err:DestinyError? = nil
        let read = mutableSpan.withUnsafeMutableBufferPointer { p in
            do throws(DestinyError) {
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
    /// - Throws: `DestinyError`
    mutating func startLine(fileDescriptor: some FileDescriptor) throws(DestinyError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMD(buffer: initialBuffer!)
    }

    /// - Throws: `DestinyError`
    mutating func startLineLowercased(fileDescriptor: some FileDescriptor) throws(DestinyError) -> SIMD64<UInt8> {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

#if RequestBody

// MARK: Body
extension AbstractHTTPRequest {
    /// - Throws: `DestinyError`
    mutating func bodyCollect<let count: Int>(fileDescriptor: some FileDescriptor) throws(DestinyError) -> InlineByteBuffer<count> {
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
    /// - Throws: `DestinyError`
    mutating func isMethod(fileDescriptor: some FileDescriptor, _ method: some HTTPRequestMethodProtocol) throws(DestinyError) -> Bool {
        if initialBuffer == nil {
            try loadStorage(fileDescriptor: fileDescriptor)
        }
        return method.rawNameString() == storage.methodString(buffer: initialBuffer!)
    }
}

#endif
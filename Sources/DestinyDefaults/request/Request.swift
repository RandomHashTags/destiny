
import DestinyBlueprint

/// Default storage for request data.
public struct Request: HTTPRequestProtocol, ~Copyable {
    public typealias Buffer = InlineArray<1024, UInt8>

    @usableFromInline
    let fileDescriptor:Int32

    @usableFromInline
    var _storage:_Storage

    @usableFromInline
    var initialBuffer:Buffer? = nil

    public var storage:Storage

    #if Inlinable
    @inlinable
    #endif
    public init(
        fileDescriptor: Int32,
        storage: consuming Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        self._storage = .init()
        self.storage = storage
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func headers() throws(SocketError) -> [String:String] {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage._headers!.headers
    }
}

// MARK: Protocol conformance
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        let path = _storage.path(buffer: initialBuffer!)
        var i = offset
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func path(at index: Int) throws(SocketError) -> String {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.path(buffer: initialBuffer!)[index]
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func pathCount() throws(SocketError) -> Int {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.path(buffer: initialBuffer!).count
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return method.rawNameString() == _storage.methodString(buffer: initialBuffer!)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func header(forKey key: String) throws(SocketError) -> String? {
        return try headers()[key]
    }

    #if Inlinable
    @inlinable
    #endif
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c._storage = _storage.copy()
        c.storage = storage.copy()
        return c
    }
}

// MARK: Load
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> Self {
        Self(fileDescriptor: socket.fileDescriptor)
    }
}

// MARK: Load storage
extension Request {
    /// Loads `initialBuffer` and `_storage`.
    #if Inlinable
    @inlinable
    #endif
    mutating func loadStorage() throws(SocketError) {
        let (initialBuffer, read) = try readBuffer()
        if read <= 0 {
            throw .malformedRequest()
        }
        self.initialBuffer = initialBuffer
        try _storage.load(
            fileDescriptor: fileDescriptor,
            buffer: initialBuffer
        )
    }
}

// MARK: Read buffer
extension Request {
    /// - Warning: **DOESN'T** check if the read bytes are >= 0!
    #if Inlinable
    @inlinable
    #endif
    func readBuffer() throws(SocketError) -> (Buffer, Int) {
        var buffer = Buffer.init(repeating: 0)
        var mutableSpan = buffer.mutableSpan
        var err:SocketError? = nil
        let read = mutableSpan.withUnsafeMutableBufferPointer { p in
            do throws(SocketError) {
                return try fileDescriptor.readBuffer(into: p.baseAddress!, length: Buffer.count, flags: 0)
            } catch {
                err = error
                return -1
            }
        }
        if let err {
            throw err
        }
        return (buffer, read)
    }
}

// MARK: Start line
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.startLineSIMD(buffer: initialBuffer!)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

// MARK: Body
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect() throws -> (buffer: Buffer, read: Int) {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return try _storage._body!.collect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect<let bufferCount: Int>() throws -> (buffer: InlineArray<bufferCount, UInt8>, read: Int) {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return try _storage._body!.collect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream(
        _ yield: (Buffer) async throws -> Void
    ) async throws {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        try await _storage._body!.stream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream<let bufferCount: Int>(
        _ yield: (InlineArray<bufferCount, UInt8>) async throws -> Void
    ) async throws {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        try await _storage._body!.stream(fileDescriptor: fileDescriptor, yield)
    }
}

import DestinyBlueprint
import DestinyDefaults

/// Default storage for request data.
struct TestRequest: HTTPRequestProtocol, ~Copyable {
    let fileDescriptor:TestFileDescriptor

    var initialBuffer:Request.Buffer? = nil
    var _storage:Request._Storage
    var storage:Request.Storage

    init(
        fileDescriptor: TestFileDescriptor,
        storage: consuming Request.Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        self._storage = .init()
        self.storage = storage
    }

    lazy var headers: HTTPHeaders = {
        return .init()
    }()

    mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        var i = offset
        if _storage.requestLine == nil {
            try loadStorage()
        }
        let path = _storage.path(buffer: initialBuffer!)
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    mutating func path(at index: Int) throws(SocketError) -> String {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.path(buffer: initialBuffer!)[index]
    }

    mutating func pathCount() throws(SocketError) -> Int {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.path(buffer: initialBuffer!).count
    }

    mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if _storage._methodString == nil {
            try loadStorage()
        }
        return method.rawNameString() == _storage._methodString
    }

    mutating func header(forKey key: String) -> String? {
        headers[key]
    }

    static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> TestRequest {
        .init(fileDescriptor: .init(fileDescriptor: socket.fileDescriptor))
    }

    func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c._storage = _storage.copy()
        c.storage = storage.copy()
        return c
    }
}

// MARK: Start line
extension TestRequest {
    mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.startLineSIMD(buffer: initialBuffer!)
    }

    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.requestLine == nil {
            try loadStorage()
        }
        return _storage.startLineSIMDLowercased(buffer: initialBuffer!)
    }
}

// MARK: Storage
extension TestRequest {
    #if Inlinable
    @inlinable
    #endif
    mutating func loadStorage() throws(SocketError) {
        let (buffer, read) = readBuffer()
        if read <= 0 {
            throw .malformedRequest()
        }
        initialBuffer = buffer
        try _storage.load(fileDescriptor: fileDescriptor, buffer: buffer)
    }
}

// MARK: Read buffer
extension TestRequest {
    func readBuffer() -> (Request.Buffer, Int) {
        var buffer = Request.Buffer.init(repeating: 0)
        var mutableSpan = buffer.mutableSpan
        let read = mutableSpan.withUnsafeMutableBufferPointer { p in
            return fileDescriptor.readBuffer(into: p.baseAddress!, length: Request.Buffer.count, flags: 0)
        }
        return (buffer, read)
    }
}
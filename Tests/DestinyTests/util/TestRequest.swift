
import DestinyBlueprint
import DestinyDefaults

/// Default storage for request data.
struct TestRequest: HTTPRequestProtocol {
    typealias Buffer = InlineArray<1024, UInt8>

    let fileDescriptor:TestFileDescriptor

    var _storage:_Storage

    var storage:Request.Storage

    init(
        fileDescriptor: TestFileDescriptor,
        storage: Request.Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        self._storage = .init()
        self.storage = storage
    }

    lazy var headers: HTTPHeaders = {
        return .init()
    }()

    lazy var __startLineLowercase: SIMD64<UInt8> = {
        return _storage._startLine!.lowercased()
    }()

    mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        var i = offset
        if _storage._pathString == nil {
            try _loadStorage()
        }
        let path = _storage._path
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    mutating func path(at index: Int) throws(SocketError) -> String {
        if _storage._pathString == nil {
            try _loadStorage()
        }
        return _storage._path[index]
    }

    mutating func pathCount() throws(SocketError) -> Int {
        if _storage._pathString == nil {
            try _loadStorage()
        }
        return _storage._path.count
    }

    mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if _storage._methodString == nil {
            try _loadStorage()
        }
        return method.rawNameString() == _storage._methodString
    }

    mutating func header(forKey key: String) -> String? {
        headers[key]
    }

    func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c._storage = _storage
        return c
    }
}

// MARK: Start line
extension TestRequest {
    mutating func startLine() throws(SocketError) -> DestinyRoutePathType {
        if _storage._startLine == nil {
            try _loadStorage()
        }
        return _storage._startLine!
    }

    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage._startLine == nil {
            try _loadStorage()
        }
        return __startLineLowercase
    }
}

// MARK: _Storage
extension TestRequest {
    mutating func _loadStorage() throws(SocketError) {
        let (buffer, read) = readBuffer()
        if read <= 0 {
            throw .malformedRequest("\(#function);read=\(read)")
        }
        var startLine = SIMD64<UInt8>()
        try HTTPStartLine.load(buffer: buffer, { sl in
            for i in 0..<min(64, sl.endIndex) {
                startLine[i] = buffer.itemAt(index: i)
            }
            _storage._startLine = startLine
            _storage._methodString = sl.method.unsafeString()
            _storage._pathString = sl.path.unsafeString()
        })
    }

    struct _Storage: Sendable {
        var _startLine:SIMD64<UInt8>? = nil

        var _methodString:String? = nil

        var _pathString:String? = nil

        init(
            //_buffer: Buffer? = nil,
            _startLine: SIMD64<UInt8>? = nil,
            _methodString: String? = nil,
            _pathString: String? = nil
        ) {
            self._startLine = _startLine
            self._methodString = _methodString
            self._pathString = _pathString
        }

        lazy var _path: [String] = {
            _pathString?.split(separator: "/").map({ String($0) }) ?? []
        }()
    }
}

// MARK: Read buffer
extension TestRequest {
    func readBuffer() -> (Buffer, Int) {
        var buffer = Buffer.init(repeating: 0)
        var mutableSpan = buffer.mutableSpan
        let read = mutableSpan.withUnsafeMutableBufferPointer { p in
            return fileDescriptor.readBuffer(into: p.baseAddress!, length: Buffer.count, flags: 0)
        }
        return (buffer, read)
    }
}
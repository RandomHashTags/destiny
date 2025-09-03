
import DestinyBlueprint
import DestinyDefaults

/// Default storage for request data.
struct TestRequest: HTTPRequestProtocol, ~Copyable {
    typealias Buffer = InlineArray<1024, UInt8>

    let fileDescriptor:TestFileDescriptor

    var _storage:_Storage

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
        if _storage.startLine == nil {
            try _loadStorage()
        }
        let path = _storage.path()
        while i < path.count {
            yield(path[i])
            i += 1
        }
    }

    mutating func path(at index: Int) throws(SocketError) -> String {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.path()[index]
    }

    mutating func pathCount() throws(SocketError) -> Int {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.path().count
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
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.startLineSIMD()
    }

    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.startLineSIMDLowercased()
    }
}

// MARK: Storage
extension TestRequest {
    #if Inlinable
    @inlinable
    #endif
    mutating func _loadStorage() throws(SocketError) {
        let (buffer, read) = readBuffer()
        if read <= 0 {
            throw .malformedRequest()
        }
        _storage.startLine = try HTTPStartLine<1024>.load(buffer: buffer)

        /*if let queryStartIndex = startLine.pathQueryStartIndex {
            print("Request;\(#function);queryStartIndex=\(queryStartIndex);query=")
            for i in queryStartIndex..<startLine.pathEndIndex {
                print("\(Character(UnicodeScalar(buffer[i])))")
            }
        }
        for i in 0..<min(64, startLine.endIndex) {
            simdStartLine[i] = buffer.itemAt(index: i)
        }
        _storage._startLineSIMD = simdStartLine
        _storage._methodString = startLine.method.unsafeString()
        _storage._pathString = startLine.path.unsafeString()*/
    }

    @usableFromInline
    struct _Storage: Sendable, ~Copyable {
        @usableFromInline
        var startLine:HTTPStartLine<1024>?

        @usableFromInline
        var _startLineSIMD:SIMD64<UInt8>?

        @usableFromInline
        var _startLineSIMDLowercased:SIMD64<UInt8>?

        @usableFromInline
        var _methodString:String?

        @usableFromInline
        var _path:[String]?

        @usableFromInline
        init(
            startLine: HTTPStartLine<1024>? = nil,
            _startLineSIMD: SIMD64<UInt8>? = nil,
            _startLineSIMDLowercased: SIMD64<UInt8>? = nil,
            _methodString: String? = nil,
            _path: [String]? = nil
        ) {
            self.startLine = startLine
            self._startLineSIMD = _startLineSIMD
            self._startLineSIMDLowercased = _startLineSIMDLowercased
            self._methodString = _methodString
            self._path = _path
        }

        #if Inlinable
        @inlinable
        #endif
        mutating func startLineSIMDLowercased() -> SIMD64<UInt8> {
            if let _startLineSIMDLowercased {
                return _startLineSIMDLowercased
            }
            let simd = startLineSIMD().lowercased()
            _startLineSIMDLowercased = simd
            return simd
        }

        #if Inlinable
        @inlinable
        #endif
        mutating func startLineSIMD() -> SIMD64<UInt8> {
            if let _startLineSIMD {
                return _startLineSIMD
            }
            var simdStartLine = SIMD64<UInt8>()
            startLine!.buffer.withUnsafeBufferPointer {
                for i in 0..<min(64, startLine!.endIndex) {
                    simdStartLine[i] = $0[i]
                }
            }
            _startLineSIMD = simdStartLine
            return simdStartLine
        }

        #if Inlinable
        @inlinable
        #endif
        mutating func methodString() -> String {
            if let _methodString {
                return _methodString
            }
            startLine!.method {
                _methodString = $0.unsafeString()
            }
            return _methodString!
        }

        #if Inlinable
        @inlinable
        #endif
        mutating func path() -> [String] {
            if let _path {
                return _path
            }
            startLine!.path({
                _path = $0.unsafeString().split(separator: "/").map({ String($0) })
            })
            return _path!
        }

        #if Inlinable
        @inlinable
        #endif
        func copy() -> Self {
            Self(
                startLine: startLine,
                _startLineSIMD: _startLineSIMD,
                _startLineSIMDLowercased: _startLineSIMDLowercased,
                _methodString: _methodString,
                _path: _path
            )
        }
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
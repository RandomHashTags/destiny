
import DestinyBlueprint

/// Default storage for request data.
public struct Request: HTTPRequestProtocol {
    public typealias Buffer = InlineArray<1024, UInt8>

    @usableFromInline
    let fileDescriptor:Int32

    @usableFromInline
    var _storage:_Storage

    public var storage:Storage

    @inlinable
    public init(
        fileDescriptor: Int32,
        storage: Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        self._storage = .init()
        self.storage = storage
    }

    public lazy var headers: HTTPHeaders = {
        /*
        // performance falls off a cliff parsing headers; should we
        // just retain the buffer and record the start and end indexes
        // of things, with computed properties when and where necessary?
        var headers:[String:String] = [:]
        //let _ = Self.parseHeaders(buffer: buffer, offset: newStartLine.endIndex + 2, headers: &headers)

        while true {
            if read < buffer.count {
                break
            }
            (buffer, read) = try socket.readBuffer()
            if read <= 0 {
                break
            }
        }*/
        return .init()
    }()

    @usableFromInline
    lazy var __startLineLowercase: SIMD64<UInt8> = {
        return _storage._startLine!.lowercased()
    }()

    @inlinable
    public mutating func forEachPath(
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

    @inlinable
    public mutating func path(at index: Int) throws(SocketError) -> String {
        if _storage._pathString == nil {
            try _loadStorage()
        }
        return _storage._path[index]
    }

    @inlinable
    public mutating func pathCount() throws(SocketError) -> Int {
        if _storage._pathString == nil {
            try _loadStorage()
        }
        return _storage._path.count
    }

    @inlinable
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if _storage._methodString == nil {
            try _loadStorage()
        }
        return method.rawNameString() == _storage._methodString
    }

    @inlinable
    public mutating func header(forKey key: String) -> String? {
        headers[key]
    }

    @inlinable
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c._storage = _storage
        return c
    }
}

// MARK: Start line
extension Request {
    @inlinable
    public mutating func startLine() throws(SocketError) -> DestinyRoutePathType {
        if _storage._startLine == nil {
            try _loadStorage()
        }
        return _storage._startLine!
    }

    @inlinable
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage._startLine == nil {
            try _loadStorage()
        }
        return __startLineLowercase
    }
}

// MARK: _Storage
extension Request {
    @usableFromInline
    mutating func _loadStorage() throws(SocketError) {
        let (buffer, read) = try readBuffer()
        if read <= 0 {
            throw .malformedRequest()
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

    @usableFromInline
    struct _Storage: Sendable {
        //@usableFromInline
        //var _buffer:Buffer? = nil

        @usableFromInline
        var _startLine:SIMD64<UInt8>? = nil

        @usableFromInline
        var _methodString:String? = nil

        @usableFromInline
        var _pathString:String? = nil

        @usableFromInline
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

        @usableFromInline
        lazy var _path: [String] = {
            _pathString?.split(separator: "/").map({ String($0) }) ?? []
        }()
    }
}

// MARK: Read buffer
extension Request {
    @inlinable
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

// MARK: Parse Headers
extension Request {
    @inlinable
    public static func parseHeaders(
        buffer: some InlineByteArrayProtocol,
        offset: Int,
        headers: inout [String:String]
    ) {
        var skip:UInt8 = 0
        let nextLine = InlineArray<256, UInt8>(repeating: 0)
        let _:InlineArray<256, UInt8>? = buffer.split(
            separators: .carriageReturn, .lineFeed,
            defaultValue: 0,
            offset: offset,
            yield: { slice in
                if skip == 2 { // content
                } else if slice == nextLine {
                    skip += 1
                } else { // header
                    let (key, colonIndex):(InlineArray<256, UInt8>, Int) = slice.firstSlice(separator: .colon, defaultValue: 0)
                    let value:InlineArray<256, UInt8> = slice.slice(startIndex: colonIndex+2, endIndex: slice.endIndex, defaultValue: 0) //  skip the colon & adjacent space
                    headers[key.string()] = value.string()
                }
                //print("slice=\(slice.string())")
            }
        )
    }
}
extension Request {
    @inlinable
    public static func parseHeaders2(
        buffer: some InlineByteArrayProtocol,
        offset: Int,
        headers: inout [String:String]
    ) {
        let bufferCount = buffer.count
        let carriageReturnSIMD = SIMD64<UInt8>(repeating: .carriageReturn)
        var startIndex = offset
        var slice = SIMD64<UInt8>.zero
        var storage = Headers<128>()
        var i = offset
        while i < bufferCount {
            let remaining = bufferCount - i
            let simdCount:Int
            if remaining >= 64 {
                simdCount = 64
                slice = buffer.simd64(startIndex: i)
            } else {
                simdCount = remaining
                slice = .zero
                for j in 0..<simdCount {
                    slice[j] = buffer.itemAt(index: i + j)
                }
            }
            parseHeaders(
                carriageReturnSIMD: carriageReturnSIMD,
                simd: slice,
                simdCount: simdCount,
                storage: &storage,
                offset: i,
                startIndex: &startIndex
            )
            i += simdCount
        }
    }
    @inlinable
    static func parseHeaders<let maxHeadersCount: Int>(
        carriageReturnSIMD: SIMD64<UInt8>,
        simd: SIMD64<UInt8>,
        simdCount: Int,
        storage: inout Headers<maxHeadersCount>,
        offset: Int,
        startIndex: inout Int
    ) {
        guard (simd .== carriageReturnSIMD) != .init(repeating: false) else { return }
        for i in 0..<simdCount {
            if simd[i] == .carriageReturn {
                storage.append(.init(startIndex: startIndex, endIndex: offset + i))
                startIndex = offset + i + 2
            }
        }
    }
}

extension Request {
    public struct Headers<let maxHeadersCount: Int>: Sendable {
        public var count:Int = 0
        public var values:InlineArray<maxHeadersCount, HeaderIndex>

        public init() {
            self.count = 0
            self.values = .init(repeating: .init(startIndex: 0, endIndex: 0))
        }

        @inlinable
        public var indices: Range<Int> {
            0..<count
        }

        @inlinable
        public mutating func append(_ index: HeaderIndex) {
            //guard index.startIndex < index.endIndex, count < maxHeadersCount else { return }
            values[count] = index
            count += 1
        }
    }
    public struct HeaderIndex: Sendable {
        let startIndex:Int
        let endIndex:Int

        public init(startIndex: Int, endIndex: Int) {
            self.startIndex = startIndex
            self.endIndex = endIndex
        }
    }
}
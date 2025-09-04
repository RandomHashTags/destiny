
import DestinyBlueprint
import VariableLengthArray

/// Default storage for request data.
public struct Request: HTTPRequestProtocol, ~Copyable {
    public typealias Buffer = InlineArray<1024, UInt8>

    @usableFromInline
    let fileDescriptor:Int32

    @usableFromInline
    var _storage:_Storage

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

    #if Inlinable
    @inlinable
    #endif
    public mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        let path = _storage.path()
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
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.path()[index]
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func pathCount() throws(SocketError) -> Int {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.path().count
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return method.rawNameString() == _storage.methodString()
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func header(forKey key: String) -> String? {
        headers[key]
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

// MARK: Start line
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.startLineSIMD()
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        if _storage.startLine == nil {
            try _loadStorage()
        }
        return _storage.startLineSIMDLowercased()
    }
}

// MARK: _Storage
extension Request {
    #if Inlinable
    @inlinable
    #endif
    mutating func _loadStorage() throws(SocketError) {
        let (buffer, read) = try readBuffer()
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
            startLine: consuming HTTPStartLine<1024>? = nil,
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
            _startLineSIMD = startLine!.simd()
            return _startLineSIMD!
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
                startLine: startLine?.copy(),
                _startLineSIMD: _startLineSIMD,
                _startLineSIMDLowercased: _startLineSIMDLowercased,
                _methodString: _methodString,
                _path: _path
            )
        }
    }
}

// MARK: Read buffer
extension Request {
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

// MARK: Parse Headers
extension Request {
    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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

        #if Inlinable
        @inlinable
        #endif
        public var indices: Range<Int> {
            0..<count
        }

        #if Inlinable
        @inlinable
        #endif
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
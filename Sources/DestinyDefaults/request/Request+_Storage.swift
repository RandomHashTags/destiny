
import DestinyBlueprint
import VariableLengthArray

extension Request {
    @usableFromInline
    package struct _Storage<FD: FileDescriptor>: Sendable, ~Copyable {
        @usableFromInline package fileprivate(set) var startLine:HTTPRequestLine?
        @usableFromInline package fileprivate(set) var _startLineSIMD:SIMD64<UInt8>?
        @usableFromInline package fileprivate(set) var _startLineSIMDLowercased:SIMD64<UInt8>?
        @usableFromInline package fileprivate(set) var _methodString:String?
        @usableFromInline package fileprivate(set) var _path:[String]?

        @usableFromInline var _headers:RequestHeaders?
        @usableFromInline var _body:RequestBody<FD>?

        @usableFromInline
        package init(
            startLine: consuming HTTPRequestLine? = nil,
            headers: consuming RequestHeaders? = nil,
            body: consuming RequestBody<FD>? = nil,
            _startLineSIMD: SIMD64<UInt8>? = nil,
            _startLineSIMDLowercased: SIMD64<UInt8>? = nil,
            _methodString: String? = nil,
            _path: [String]? = nil
        ) {
            self.startLine = startLine
            self._headers = headers
            self._body = body
            self._startLineSIMD = _startLineSIMD
            self._startLineSIMDLowercased = _startLineSIMDLowercased
            self._methodString = _methodString
            self._path = _path
        }
    }
}

// MARK: Load
extension Request._Storage {
    /// Lodas `startLine`, `_headers` and `_body`.
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func load<let count: Int>(
        fileDescriptor: FD,
        buffer: InlineArray<count, UInt8>
    ) throws(SocketError) {
        let requestLine = try HTTPRequestLine.load(buffer: buffer)
        _headers = RequestHeaders(startIndex: requestLine.endIndex + 2)
        startLine = consume requestLine
        _body = .init(fileDescriptor: fileDescriptor)
    }
}

// MARK: Start Line SIMD
extension Request._Storage {
    /// - Warning: `startLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func startLineSIMD<let count: Int>(buffer: InlineArray<count, UInt8>) -> SIMD64<UInt8> {
        if let _startLineSIMD {
            return _startLineSIMD
        }
        _startLineSIMD = startLine!.simd(buffer: buffer)
        return _startLineSIMD!
    }

    /// - Warning: `startLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func startLineSIMDLowercased<let count: Int>(buffer: InlineArray<count, UInt8>) -> SIMD64<UInt8> {
        if let _startLineSIMDLowercased {
            return _startLineSIMDLowercased
        }
        let simd = startLineSIMD(buffer: buffer).lowercased()
        _startLineSIMDLowercased = simd
        return simd
    }
}

// MARK: Method
extension Request._Storage {
    /// - Warning: `startLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func methodString<let count: Int>(buffer: InlineArray<count, UInt8>) -> String {
        if let _methodString {
            return _methodString
        }
        startLine!.method(buffer: buffer) {
            _methodString = $0.unsafeString()
        }
        return _methodString!
    }
}

// MARK: Path
extension Request._Storage {
    /// - Warning: `startLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func path<let count: Int>(buffer: InlineArray<count, UInt8>) -> [String] {
        if let _path {
            return _path
        }
        startLine!.path(buffer: buffer, {
            _path = $0.unsafeString().split(separator: "/").map({ String($0) })
        })
        return _path!
    }
}

// MARK: Copy
extension Request._Storage {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package func copy() -> Self {
        Self(
            startLine: startLine?.copy(),
            _startLineSIMD: _startLineSIMD,
            _startLineSIMDLowercased: _startLineSIMDLowercased,
            _methodString: _methodString,
            _path: _path
        )
    }
}

import DestinyBlueprint
import VariableLengthArray

extension Request {
    @usableFromInline
    package struct _Storage: Sendable, ~Copyable {
        @usableFromInline package fileprivate(set) var requestLine:HTTPRequestLine?
        @usableFromInline package fileprivate(set) var _startLineSIMD:SIMD64<UInt8>?
        @usableFromInline package fileprivate(set) var _startLineSIMDLowercased:SIMD64<UInt8>?
        @usableFromInline package fileprivate(set) var _methodString:String?
        @usableFromInline package fileprivate(set) var _path:[String]?

        @usableFromInline var _headers:RequestHeaders?
        @usableFromInline var _body:RequestBody?

        @usableFromInline
        package init(
            requestLine: consuming HTTPRequestLine? = nil,
            headers: consuming RequestHeaders? = nil,
            body: consuming RequestBody? = nil,
            _startLineSIMD: SIMD64<UInt8>? = nil,
            _startLineSIMDLowercased: SIMD64<UInt8>? = nil,
            _methodString: String? = nil,
            _path: [String]? = nil
        ) {
            self.requestLine = requestLine
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
    /// Loads `requestLine`, `_headers` and `_body`.
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    package mutating func load<let count: Int>(
        fileDescriptor: some FileDescriptor,
        buffer: InlineArray<count, UInt8>
    ) throws(SocketError) {
        let requestLine = try HTTPRequestLine.load(buffer: buffer)
        _headers = RequestHeaders(startIndex: requestLine.endIndex + 2)
        self.requestLine = consume requestLine
        _body = .init()
    }
}

// MARK: Start Line SIMD
extension Request._Storage {
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
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
        _startLineSIMD = requestLine!.simd(buffer: buffer)
        return _startLineSIMD!
    }

    /// - Warning: `requestLine` **MUST NOT** be `nil`!
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
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
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
        requestLine!.method(buffer: buffer) {
            _methodString = $0.unsafeString()
        }
        return _methodString!
    }
}

// MARK: Path
extension Request._Storage {
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
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
        requestLine!.path(buffer: buffer, {
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
            requestLine: requestLine?.copy(),
            _startLineSIMD: _startLineSIMD,
            _startLineSIMDLowercased: _startLineSIMDLowercased,
            _methodString: _methodString,
            _path: _path
        )
    }
}
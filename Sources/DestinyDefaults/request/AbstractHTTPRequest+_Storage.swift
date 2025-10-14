
import DestinyEmbedded
import UnwrapArithmeticOperators
import VariableLengthArray

extension AbstractHTTPRequest {
    /// Underlying storage for the default request implementation.
    @usableFromInline
    package struct _Storage: Sendable, ~Copyable {
        @usableFromInline fileprivate(set) var startLineSIMD:SIMD64<UInt8>?
        @usableFromInline fileprivate(set) var startLineSIMDLowercased:SIMD64<UInt8>?

        @usableFromInline fileprivate(set) var requestLine:HTTPRequestLine?
        @usableFromInline fileprivate(set) var methodString:String?
        @usableFromInline fileprivate(set) var path:[String]?

        #if RequestHeaders
        @usableFromInline package var _headers:AbstractHTTPRequest.Headers?
        #endif

        #if RequestBody
        @usableFromInline package var _body:RequestBody?
        #endif

        @usableFromInline
        init(
            requestLine: consuming HTTPRequestLine? = nil,
            startLineSIMD: SIMD64<UInt8>? = nil,
            startLineSIMDLowercased: SIMD64<UInt8>? = nil,
            methodString: String? = nil,
            path: [String]? = nil
        ) {
            self.requestLine = requestLine
            #if RequestHeaders
            self._headers = nil
            #endif
            #if RequestBody
            self._body = nil
            #endif
            self.startLineSIMD = startLineSIMD
            self.startLineSIMDLowercased = startLineSIMDLowercased
            self.methodString = methodString
            self.path = path
        }
    }
}

#if RequestHeaders

extension AbstractHTTPRequest._Storage {
    @usableFromInline
    init(
        requestLine: consuming HTTPRequestLine? = nil,
        headers: consuming AbstractHTTPRequest.Headers? = nil,
        startLineSIMD: SIMD64<UInt8>? = nil,
        startLineSIMDLowercased: SIMD64<UInt8>? = nil,
        methodString: String? = nil,
        path: [String]? = nil
    ) {
        self.requestLine = requestLine
        self._headers = headers
        #if RequestBody
        self._body = nil
        #endif
        self.startLineSIMD = startLineSIMD
        self.startLineSIMDLowercased = startLineSIMDLowercased
        self.methodString = methodString
        self.path = path
    }
}

#endif

#if RequestBody

extension AbstractHTTPRequest._Storage {
    @usableFromInline
    init(
        requestLine: consuming HTTPRequestLine? = nil,
        headers: consuming AbstractHTTPRequest.Headers? = nil,
        body: consuming RequestBody? = nil,
        startLineSIMD: SIMD64<UInt8>? = nil,
        startLineSIMDLowercased: SIMD64<UInt8>? = nil,
        methodString: String? = nil,
        path: [String]? = nil
    ) {
        self.requestLine = requestLine
        self._headers = headers
        self._body = body
        self.startLineSIMD = startLineSIMD
        self.startLineSIMDLowercased = startLineSIMDLowercased
        self.methodString = methodString
        self.path = path
    }
}

#endif

// MARK: Load
extension AbstractHTTPRequest._Storage {
    /// Loads `requestLine`, `_headers` and `_body`.
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func load<let count: Int>(
        buffer: borrowing InlineByteBuffer<count>
    ) throws(SocketError) {
        let requestLine = try HTTPRequestLine.load(buffer: buffer)

        #if RequestHeaders
        _headers = AbstractHTTPRequest.Headers(startIndex: requestLine.endIndex +! 2)
        #endif

        self.requestLine = consume requestLine

        #if RequestBody
        _body = .init()
        #endif
    }
}

// MARK: Start Line SIMD
extension AbstractHTTPRequest._Storage {
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func startLineSIMD<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> SIMD64<UInt8> {
        if let startLineSIMD {
            return startLineSIMD
        }
        startLineSIMD = requestLine!.simd(buffer: buffer.buffer)
        return startLineSIMD!
    }

    /// - Warning: `requestLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func startLineSIMDLowercased<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> SIMD64<UInt8> {
        if let startLineSIMDLowercased {
            return startLineSIMDLowercased
        }
        let simd = startLineSIMD(buffer: buffer).lowercased()
        startLineSIMDLowercased = simd
        return simd
    }
}

// MARK: Method
extension AbstractHTTPRequest._Storage {
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func methodString<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> String {
        if let methodString {
            return methodString
        }
        requestLine!.method(buffer: buffer.buffer) {
            methodString = $0.unsafeString()
        }
        return methodString!
    }
}

// MARK: Path
extension AbstractHTTPRequest._Storage {
    /// - Warning: `requestLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func path<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> [String] {
        if let path {
            return path
        }
        requestLine!.path(buffer: buffer.buffer, {
            path = [String]()
            var startIndex = 0
            for i in $0.indices {
                if $0.storage[i] == .forwardSlash {
                    if startIndex < i {
                        path!.append($0.unsafeString(startIndex: startIndex, endIndex: i))
                    }
                    startIndex = i +! 1
                }
            }
            if startIndex < $0.count {
                path!.append($0.unsafeString(startIndex: startIndex, endIndex: $0.count))
            }
        })
        return path!
    }
}

#if RequestBody

// MARK: Body
extension AbstractHTTPRequest._Storage {
    /// - Warning: `_headers` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    mutating func bodyCollect<let initialBufferCount: Int, let bufferCount: Int>(
        fileDescriptor: some FileDescriptor,
        initialBuffer: borrowing InlineByteBuffer<initialBufferCount>
    ) throws(SocketError) -> InlineByteBuffer<bufferCount> {
        if _headers!._endIndex == nil {
            _headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer)
        }
        return try _body!.collect(fileDescriptor: fileDescriptor)
    }
}

#endif

// MARK: Copy
extension AbstractHTTPRequest._Storage {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    func copy() -> Self {
        Self(
            requestLine: requestLine?.copy(),
            startLineSIMD: startLineSIMD,
            startLineSIMDLowercased: startLineSIMDLowercased,
            methodString: methodString,
            path: path
        )
    }
}

import DestinyBlueprint
import VariableLengthArray

extension Request {
    @usableFromInline
    struct _Storage: Sendable, ~Copyable {
        @usableFromInline fileprivate(set) var requestLine:HTTPRequestLine?
        @usableFromInline fileprivate(set) var _startLineSIMD:SIMD64<UInt8>?
        @usableFromInline fileprivate(set) var _startLineSIMDLowercased:SIMD64<UInt8>?
        @usableFromInline fileprivate(set) var _methodString:String?
        @usableFromInline fileprivate(set) var _path:[String]?

        @usableFromInline var _headers:RequestHeaders?
        @usableFromInline var _body:RequestBody?

        @usableFromInline
        init(
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
    mutating func load<let count: Int>(
        buffer: borrowing InlineByteBuffer<count>
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
    mutating func startLineSIMD<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> SIMD64<UInt8> {
        if let _startLineSIMD {
            return _startLineSIMD
        }
        _startLineSIMD = requestLine!.simd(buffer: buffer.buffer)
        return _startLineSIMD!
    }

    /// - Warning: `requestLine` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    mutating func startLineSIMDLowercased<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> SIMD64<UInt8> {
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
    mutating func methodString<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> String {
        if let _methodString {
            return _methodString
        }
        requestLine!.method(buffer: buffer.buffer) {
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
    mutating func path<let count: Int>(buffer: borrowing InlineByteBuffer<count>) -> [String] {
        if let _path {
            return _path
        }
        requestLine!.path(buffer: buffer.buffer, {
            _path = $0.unsafeString().split(separator: "/").map({ String($0) })
        })
        return _path!
    }
}

// MARK: Body
extension Request._Storage {
    /// - Warning: `_headers` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    mutating func bodyCollect<let initialBufferCount: Int, let bufferCount: Int>(
        fileDescriptor: some FileDescriptor,
        initialBuffer: borrowing InlineByteBuffer<initialBufferCount>
    ) throws -> InlineByteBuffer<bufferCount> {
        if _headers!._endIndex == nil {
            _headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer)
        }
        return try _body!.collect(fileDescriptor: fileDescriptor)
    }

    /// - Warning: `_headers` **MUST NOT** be `nil`!
    #if Inlinable
    @inlinable
    #endif
    mutating func bodyStream<let initialBufferCount: Int, let bufferCount: Int>(
        fileDescriptor: some FileDescriptor,
        initialBuffer: borrowing InlineByteBuffer<initialBufferCount>,
        _ yield: (consuming InlineByteBuffer<bufferCount>) async throws -> Void
    ) async throws {
        if _headers!._endIndex == nil {
            _headers!.load(fileDescriptor: fileDescriptor, initialBuffer: initialBuffer)
            var startIndex = _headers!._endIndex! + 2
            if startIndex < initialBufferCount {
                // part of the request body is contained in the initial buffer
                var buffer = InlineArray<bufferCount, UInt8>(repeating: 0)
                var initialRequestBodyCount = initialBuffer.endIndex - startIndex
                var remainingRequestBodyCount = initialRequestBodyCount
                initialBuffer.buffer.withUnsafeBufferPointer { initialBufferPointer in
                    buffer.withUnsafeMutableBufferPointer {
                        var bufferPointer = $0
                        loadBufferSlice(
                            initialBufferPointer: initialBufferPointer,
                            bufferPointer: &bufferPointer,
                            index: &startIndex,
                            initialRequestBodyCount: &remainingRequestBodyCount
                        )
                    }
                }
                try await yield(.init(buffer: buffer, endIndex: initialRequestBodyCount - remainingRequestBodyCount))
                while remainingRequestBodyCount > 0 {
                    initialRequestBodyCount = remainingRequestBodyCount
                    initialBuffer.buffer.withUnsafeBufferPointer { initialBufferPointer in
                        buffer.withUnsafeMutableBufferPointer {
                            var bufferPointer = $0
                            bufferPointer.update(repeating: 0)
                            loadBufferSlice(
                                initialBufferPointer: initialBufferPointer,
                                bufferPointer: &bufferPointer,
                                index: &startIndex,
                                initialRequestBodyCount: &remainingRequestBodyCount
                            )
                        }
                    }
                    try await yield(.init(buffer: buffer, endIndex: initialRequestBodyCount - remainingRequestBodyCount))
                }
                if initialBuffer.endIndex != initialBufferCount {
                    // request body was completely within the initial buffer
                    return
                }
            }
        }
        try await _body!.stream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    mutating func loadBufferSlice(
        initialBufferPointer: UnsafeBufferPointer<UInt8>,
        bufferPointer: inout UnsafeMutableBufferPointer<UInt8>,
        index: inout Int,
        initialRequestBodyCount: inout Int
    ) {
        let bufferCount = bufferPointer.count
        let copied = min(bufferCount, initialRequestBodyCount)
        var i = 0
        while i < copied {
            bufferPointer[i] = initialBufferPointer[index]
            i += 1
            index += 1
        }
        initialRequestBodyCount -= copied
        _body!._totalRead += UInt64(copied)
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
    func copy() -> Self {
        Self(
            requestLine: requestLine?.copy(),
            _startLineSIMD: _startLineSIMD,
            _startLineSIMDLowercased: _startLineSIMDLowercased,
            _methodString: _methodString,
            _path: _path
        )
    }
}

import DestinyBlueprint
import VariableLengthArray

extension AbstractHTTPRequest {
    /// Underlying storage for the default request implementation.
    @usableFromInline
    struct _Storage: Sendable, ~Copyable {
        @usableFromInline fileprivate(set) var requestLine:HTTPRequestLine?
        @usableFromInline fileprivate(set) var startLineSIMD:SIMD64<UInt8>?
        @usableFromInline fileprivate(set) var startLineSIMDLowercased:SIMD64<UInt8>?
        @usableFromInline fileprivate(set) var methodString:String?
        @usableFromInline fileprivate(set) var path:[String]?

        @usableFromInline var _headers:AbstractHTTPRequest.Headers?
        @usableFromInline var _body:RequestBody?

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
}

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
        _headers = AbstractHTTPRequest.Headers(startIndex: requestLine.endIndex + 2)
        self.requestLine = consume requestLine
        _body = .init()
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
            path = $0.unsafeString().split(separator: "/").map({ String($0) })
        })
        return path!
    }
}

// MARK: Body
extension AbstractHTTPRequest._Storage {
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
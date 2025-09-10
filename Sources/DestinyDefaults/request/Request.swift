
import DestinyBlueprint

/// Default storage for request data.
public struct Request: HTTPRequestProtocol, ~Copyable {
    public typealias InitialBuffer = InlineByteBuffer<1024>

    @usableFromInline
    let fileDescriptor:Int32

    @usableFromInline
    var _request:_Request<1024>

    #if Inlinable
    @inlinable
    #endif
    public init(
        fileDescriptor: Int32,
        storage: consuming Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        _request = .init(storage: storage)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func headers() throws(SocketError) -> [Substring:Substring] {
        try _request.headers(fileDescriptor: fileDescriptor)
    }
}

// MARK: Protocol conformance
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        try _request.startLine(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        try _request.startLineLowercased(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        try _request.forEachPath(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func path(at index: Int) throws(SocketError) -> String {
        try _request.path(fileDescriptor: fileDescriptor, at: index)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func pathCount() throws(SocketError) -> Int {
        try _request.pathCount(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        try _request.isMethod(fileDescriptor: fileDescriptor, method)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func header(forKey key: String) throws(SocketError) -> String? {
        try _request.header(fileDescriptor: fileDescriptor, forKey: key)
    }

    #if Inlinable
    @inlinable
    #endif
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c._request = _request.copy()
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

// MARK: Body
extension Request {
    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect() throws -> InitialBuffer {
        try _request.bodyCollect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect<let count: Int>() throws -> InlineByteBuffer<count> {
        try _request.bodyCollect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream(
        _ yield: (consuming InitialBuffer) async throws -> Void
    ) async throws {
        try await _request.bodyStream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream<let count: Int>(
        _ yield: (consuming InlineByteBuffer<count>) async throws -> Void
    ) async throws {
        try await _request.bodyStream(fileDescriptor: fileDescriptor, yield)
    }
}
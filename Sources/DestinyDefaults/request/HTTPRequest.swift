
import DestinyBlueprint

/// Default storage for http request data.
public struct HTTPRequest: HTTPRequestProtocol, ~Copyable {
    public typealias InitialBuffer = InlineByteBuffer<1024>

    @usableFromInline
    let fileDescriptor:Int32

    @usableFromInline
    var abstractRequest:AbstractHTTPRequest<1024>

    #if Inlinable
    @inlinable
    #endif
    public init(
        fileDescriptor: Int32,
        storage: consuming Storage = .init([:])
    ) {
        self.fileDescriptor = fileDescriptor
        abstractRequest = .init(storage: storage)
    }

    #if Inlinable
    @inlinable
    #endif
    public func socketLocalAddress() -> String? {
        fileDescriptor.socketLocalAddress()
    }

    #if Inlinable
    @inlinable
    #endif
    public func socketPeerAddress() -> String? {
        fileDescriptor.socketPeerAddress()
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func headers() throws(SocketError) -> [Substring:Substring] {
        try abstractRequest.headers(fileDescriptor: fileDescriptor)
    }
}

// MARK: Protocol conformance
extension HTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        try abstractRequest.startLine(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        try abstractRequest.startLineLowercased(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func forEachPath(
        offset: Int = 0,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        try abstractRequest.forEachPath(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func path(at index: Int) throws(SocketError) -> String {
        try abstractRequest.path(fileDescriptor: fileDescriptor, at: index)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func pathCount() throws(SocketError) -> Int {
        try abstractRequest.pathCount(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool {
        try abstractRequest.isMethod(fileDescriptor: fileDescriptor, method)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func header(forKey key: String) throws(SocketError) -> String? {
        try abstractRequest.header(fileDescriptor: fileDescriptor, forKey: key)
    }

    #if Inlinable
    @inlinable
    #endif
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c.abstractRequest = abstractRequest.copy()
        return c
    }
}

// MARK: Load
extension HTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    public static func load(from socket: consuming some HTTPSocketProtocol & ~Copyable) throws(SocketError) -> Self {
        Self(fileDescriptor: socket.fileDescriptor)
    }
}

// MARK: Body
extension HTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect() throws -> InitialBuffer {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect<let count: Int>() throws -> InlineByteBuffer<count> {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream(
        _ yield: (consuming InitialBuffer) async throws -> Void
    ) async throws {
        try await abstractRequest.bodyStream(fileDescriptor: fileDescriptor, yield)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyStream<let count: Int>(
        _ yield: (consuming InlineByteBuffer<count>) async throws -> Void
    ) async throws {
        try await abstractRequest.bodyStream(fileDescriptor: fileDescriptor, yield)
    }
}
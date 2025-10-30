
/// Default storage for http request data.
public struct HTTPRequest: NetworkAddressable, ~Copyable {
    public typealias InitialBuffer = InlineByteBuffer<1024>

    @usableFromInline
    package let fileDescriptor:Int32

    @usableFromInline
    package var abstractRequest:AbstractHTTPRequest<1024>

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
}

// MARK: Load
extension HTTPRequest {
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public static func load(from socket: consuming some FileDescriptor & ~Copyable) throws(SocketError) -> Self {
        Self(fileDescriptor: socket.fileDescriptor)
    }
}

// MARK: General logic
extension HTTPRequest {
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

    /// The HTTP start-line.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLine() throws(SocketError) -> SIMD64<UInt8> {
        try abstractRequest.startLine(fileDescriptor: fileDescriptor)
    }

    /// The HTTP start-line in all lowercase bytes.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8> {
        try abstractRequest.startLineLowercased(fileDescriptor: fileDescriptor)
    }

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func forEachPath(
        offset: Int,
        _ yield: (String) -> Void
    ) throws(SocketError) {
        try abstractRequest.forEachPath(fileDescriptor: fileDescriptor, offset: offset, yield)
    }

    /// - Parameters:
    ///   - index: Index of a path component.
    /// 
    /// - Returns: The path component at the given index.
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func path(at index: Int) throws(SocketError) -> String {
        try abstractRequest.path(fileDescriptor: fileDescriptor, at: index)
    }

    /// Number of path components the request contains.
    /// 
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func pathCount() throws(SocketError) -> Int {
        try abstractRequest.pathCount(fileDescriptor: fileDescriptor)
    }

    /// - Returns: Whether or not the request's method matches the given one.
    /// - Throws: `SocketError`
    #if Inlinable
    @inlinable
    #endif
    public mutating func isMethod(_ method: HTTPRequestMethod) throws(SocketError) -> Bool {
        try abstractRequest.isMethod(fileDescriptor: fileDescriptor, method)
    }

    /// - Returns: The value for the corresponding header key.
    /// - Throws: `SocketError`
    /// - Warning: `key` is case-sensitive!
    #if Inlinable
    @inlinable
    #endif
    public mutating func header(forKey key: String) throws(SocketError) -> String? {
        #if RequestHeaders
        return try abstractRequest.header(fileDescriptor: fileDescriptor, forKey: key)
        #else
        return nil
        #endif
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func headers() throws(SocketError) -> [Substring:Substring] {
        #if RequestHeaders
        return try abstractRequest.headers(fileDescriptor: fileDescriptor)
        #else
        return [:]
        #endif
    }

    /// - Note: Only use if you need it (e.g. required if doing async work from a responder).
    /// - Returns: A copy of self.
    #if Inlinable
    @inlinable
    #endif
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c.abstractRequest = abstractRequest.copy()
        return c
    }
}



#if RequestBody

// MARK: Body
extension HTTPRequest {
    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect() throws(SocketError) -> InitialBuffer {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func bodyCollect<let count: Int>() throws(SocketError) -> InlineByteBuffer<count> {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }
}

#endif
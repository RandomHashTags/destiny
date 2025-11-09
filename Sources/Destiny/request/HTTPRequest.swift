
/// Default storage for http request data.
public struct HTTPRequest: NetworkAddressable, ~Copyable {
    public typealias InitialBuffer = InlineByteBuffer<1024>

    public let fileDescriptor:Int32

    @usableFromInline
    package var abstractRequest:AbstractHTTPRequest<1024>

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
    public static func load(from socket: consuming some FileDescriptor & ~Copyable) -> Self {
        Self(fileDescriptor: socket.fileDescriptor)
    }
}

// MARK: General logic
extension HTTPRequest {
    public func socketLocalAddress() -> String? {
        fileDescriptor.socketLocalAddress()
    }

    public func socketPeerAddress() -> String? {
        fileDescriptor.socketPeerAddress()
    }

    /// The HTTP start-line.
    /// 
    /// - Throws: `DestinyError`
    public mutating func startLine() throws(DestinyError) -> SIMD64<UInt8> {
        try abstractRequest.startLine(fileDescriptor: fileDescriptor)
    }

    /// The HTTP start-line in all lowercase bytes.
    /// 
    /// - Throws: `DestinyError`
    public mutating func startLineLowercased() throws(DestinyError) -> SIMD64<UInt8> {
        try abstractRequest.startLineLowercased(fileDescriptor: fileDescriptor)
    }

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    /// 
    /// - Throws: `DestinyError`
    public mutating func forEachPath(
        offset: Int,
        _ yield: (String) -> Void
    ) throws(DestinyError) {
        try abstractRequest.forEachPath(fileDescriptor: fileDescriptor, offset: offset, yield)
    }

    /// - Parameters:
    ///   - index: Index of a path component.
    /// 
    /// - Returns: The path component at the given index.
    /// - Throws: `DestinyError`
    public mutating func path(at index: Int) throws(DestinyError) -> String {
        try abstractRequest.path(fileDescriptor: fileDescriptor, at: index)
    }

    /// Number of path components the request contains.
    /// 
    /// - Throws: `DestinyError`
    public mutating func pathCount() throws(DestinyError) -> Int {
        try abstractRequest.pathCount(fileDescriptor: fileDescriptor)
    }

    /// - Returns: Whether or not the request's method matches the given one.
    /// - Throws: `DestinyError`
    public mutating func isMethod(_ method: HTTPRequestMethod) throws(DestinyError) -> Bool {
        try abstractRequest.isMethod(fileDescriptor: fileDescriptor, method)
    }

    /// - Returns: The value for the corresponding header key.
    /// - Throws: `DestinyError`
    /// - Warning: `key` is case-sensitive!
    public mutating func header(forKey key: String) throws(DestinyError) -> String? {
        #if RequestHeaders
        return try abstractRequest.header(fileDescriptor: fileDescriptor, forKey: key)
        #else
        return nil
        #endif
    }

    public mutating func headers() throws(DestinyError) -> [Substring:Substring] {
        #if RequestHeaders
        return try abstractRequest.headers(fileDescriptor: fileDescriptor)
        #else
        return [:]
        #endif
    }

    /// - Note: Only use if you need it (e.g. required if doing async work from a responder).
    /// - Returns: A copy of self.
    public func copy() -> Self {
        var c = Self(fileDescriptor: fileDescriptor)
        c.abstractRequest = abstractRequest.copy()
        return c
    }
}


#if RequestBody

// MARK: Body
extension HTTPRequest {
    public mutating func bodyCollect() throws(DestinyError) -> InitialBuffer {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }

    public mutating func bodyCollect<let count: Int>() throws(DestinyError) -> InlineByteBuffer<count> {
        try abstractRequest.bodyCollect(fileDescriptor: fileDescriptor)
    }
}

#endif


#if Protocols

// MARK: Conformances
extension HTTPRequest {
    public mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(DestinyError) -> Bool {
        try abstractRequest.isMethod(fileDescriptor: fileDescriptor, method)
    }
}

#endif

/// Core protocol that handles a socket's incoming data.
public protocol HTTPRequestProtocol: Sendable, ~Copyable {
    typealias ConcretePathType = String // TODO: allow custom

    /// The HTTP start-line.
    mutating func startLine() throws(SocketError) -> SIMD64<UInt8>

    /// The HTTP start-line in all lowercase bytes.
    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8>

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    mutating func forEachPath(
        offset: Int,
        _ yield: (ConcretePathType) -> Void
    ) throws(SocketError)

    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The path component at the given index.
    mutating func path(
        at index: Int
    ) throws(SocketError) -> ConcretePathType

    /// Number of path components the request contains.
    mutating func pathCount() throws(SocketError) -> Int

    /// - Returns: Whether or not the request's method matches the given one.
    mutating func isMethod(_ method: some HTTPRequestMethodProtocol) throws(SocketError) -> Bool

    //func header<let keyCount: Int, let valueCount: Int>(forKey key: InlineArray<keyCount, UInt8>) -> InlineArray<valueCount, UInt8>?

    mutating func header(forKey key: String) throws(SocketError) -> String?

    /// - Note: Only use if you need it (e.g. required if doing async work from a responder).
    /// - Returns: A copy of self.
    func copy() -> Self

    /// Loads this request from a socket.
    static func load(
        from socket: consuming some HTTPSocketProtocol & ~Copyable
    ) throws(SocketError) -> Self
}

/*
extension HTTPRequestProtocol where Self: ~Copyable {
    #if Inlinable
    @inlinable
    #endif
    public func isMethod(_ method: some HTTPRequestMethodProtocol) -> Bool {
        isMethod(method.rawName)
    }
}*/

/*
/// Core protocol that handles data for a request.
/// 
/// Some examples of data that is usually stored include:
/// - Authentication headers
/// - Cookies
/// - Unique IDs
public protocol RequestStorageProtocol: Sendable, ~Copyable {
    /// - Returns: The stored value for the associated key.
    func get<K, V>(key: K) -> V?
    /// Stores the value for the associated key.
    func set<K, V>(key: K, value: V?)
}*/
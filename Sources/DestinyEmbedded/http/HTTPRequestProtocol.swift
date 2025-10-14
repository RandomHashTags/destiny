
/// Core protocol that handles a socket's incoming data.
public protocol HTTPRequestProtocol: NetworkAddressable, ~Copyable {
    typealias ConcretePathType = String // TODO: allow custom

    /// The HTTP start-line.
    /// 
    /// - Throws: `SocketError`
    mutating func startLine() throws(SocketError) -> SIMD64<UInt8>

    /// The HTTP start-line in all lowercase bytes.
    /// 
    /// - Throws: `SocketError`
    mutating func startLineLowercased() throws(SocketError) -> SIMD64<UInt8>

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    /// 
    /// - Throws: `SocketError`
    mutating func forEachPath(
        offset: Int,
        _ yield: (ConcretePathType) -> Void
    ) throws(SocketError)

    /// - Parameters:
    ///   - index: Index of a path component.
    /// 
    /// - Returns: The path component at the given index.
    /// - Throws: `SocketError`
    mutating func path(
        at index: Int
    ) throws(SocketError) -> ConcretePathType

    /// Number of path components the request contains.
    /// 
    /// - Throws: `SocketError`
    mutating func pathCount() throws(SocketError) -> Int

    /// - Returns: Whether or not the request's method matches the given one.
    /// - Throws: `SocketError`
    mutating func isMethod(_ method: HTTPRequestMethod) throws(SocketError) -> Bool

    /// - Returns: The value for the corresponding header key.
    /// - Throws: `SocketError`
    /// - Warning: `key` is case-sensitive!
    mutating func header(forKey key: String) throws(SocketError) -> String?

    /// - Note: Only use if you need it (e.g. required if doing async work from a responder).
    /// - Returns: A copy of self.
    func copy() -> Self

    /*
    /// Loads this request from a socket.
    static func load(
        from socket: consuming some SocketProtocol & ~Copyable
    ) throws(SocketError) -> Self*/
}

/// Core Request protocol that lays out how a socket's incoming data is parsed.
public protocol HTTPRequestProtocol: Sendable, ~Copyable {
    typealias ConcretePathType = String // TODO: allow custom

    /// The HTTP start-line.
    var startLine: SIMD64<UInt8> { get }

    mutating func startLineLowercased() -> SIMD64<UInt8>

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    mutating func forEachPath(offset: Int, _ yield: (ConcretePathType) -> Void)

    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The path component at the given index.
    mutating func path(at index: Int) -> ConcretePathType

    /// The number of path components the request contains.
    mutating func pathCount() -> Int

    /// - Returns: Whether or not the request's method matches the given one.
    func isMethod(_ method: some HTTPRequestMethodProtocol) -> Bool

    //@inlinable func header<let keyCount: Int, valueCount: Int>(forKey key: InlineArray<keyCount, UInt8>) -> InlineArray<valueCount, UInt8>?

    mutating func header(forKey key: String) -> String?
}

/*
extension HTTPRequestProtocol where Self: ~Copyable {
    @inlinable
    public func isMethod(_ method: some HTTPRequestMethodProtocol) -> Bool {
        isMethod(method.rawName)
    }
}*/

/*
/// Core Request Storage protocol that lays out how data for a request is stored.
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
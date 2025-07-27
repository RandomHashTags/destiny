
/// Core Request protocol that lays out how a socket's incoming data is parsed.
public protocol HTTPRequestProtocol: Sendable, ~Copyable {
    typealias ConcretePathType = String // TODO: allow custom

    /// Initializes the bare minimum data required to process a socket's data.
    init?(socket: borrowing some HTTPSocketProtocol & ~Copyable) throws

    /// The HTTP start-line.
    var startLine: SIMD64<UInt8> { get }

    /// Yields the endpoint the request wants to reach, separated by the forward slash character.
    @inlinable
    func forEachPath(offset: Int, _ yield: (ConcretePathType) -> Void)

    /// - Parameters:
    ///   - index: Index of a path component.
    /// - Returns: The path component at the given index.
    @inlinable
    func path(at index: Int) -> ConcretePathType

    /// The number of path components the request contains.
    @inlinable
    var pathCount: Int { get }

    /// - Returns: Whether or not the request's method matches the given one.
    @inlinable
    func isMethod<let count: Int>(_ method: InlineArray<count, UInt8>) -> Bool

    //@inlinable func header<let keyCount: Int, valueCount: Int>(forKey key: InlineArray<keyCount, UInt8>) -> InlineArray<valueCount, UInt8>?

    @inlinable
    func header(forKey key: String) -> String?
}

/*
extension HTTPRequestProtocol where Self: ~Copyable {
    @inlinable
    public func isMethod<T: HTTPRequestMethodProtocol>(_ method: T) -> Bool {
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
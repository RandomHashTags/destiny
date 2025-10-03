
extension HTTPHeaders: HTTPHeadersProtocol {}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    /// Creates an instance initialized with the given key-value pairs.
    /// - Warning: Keys are case-sensitive!
    #if Inlinable
    @inlinable
    #endif
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var _storage = [(Key, Value)]()
        _storage.reserveCapacity(elements.count)
        for (key, value) in elements {
            _storage.append((key, value))
        }
        self.init(_storage: _storage)
    }
}
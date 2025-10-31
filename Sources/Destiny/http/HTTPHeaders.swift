
/// Default storage for an HTTP Message's headers.
/// 
/// - Warning: Keys are case-sensitive!
public struct HTTPHeaders: Sendable {
    @usableFromInline
    package var _storage:[(key: String, value: String)]

    /// - Warning: Keys are case-sensitive!
    public init(_storage: [(String, String)] = []) {
        self._storage = _storage
    }

    /// - Warning: Keys are case-sensitive!
    public init(_ storage: [String:String]) {
        var array = [(String, String)]()
        array.reserveCapacity(storage.count)
        for (key, value) in storage {
            array.append((key, value))
        }
        self._storage = array
    }

    /// Reserves enough space to store the specified number of elements.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _storage.reserveCapacity(minimumCapacity)
    }
}

extension HTTPHeaders {
    /// - Complexity: On average, reading/writing an existing header is O(_n_) while removing a header is O(2*n*) if it exists and O(_n_) if it doesn't.
    /// - Warning: `header` is case-sensitive!
    public subscript(header: String) -> String? {
        get {
            _storage.first(where: { $0.key == header })?.value
        }
        set {
            if let index = _storage.firstIndex(where: { $0.key == header }) {
                if let newValue {
                    _storage[index].value = newValue
                } else {
                    _storage.remove(at: index)
                }
            } else if let newValue {
                _storage.append((header, newValue))
            }
        }
    }

    /// Whether or not the given header exists.
    /// 
    /// - Complexity: O(_n_).
    /// - Warning: `header` is case-sensitive!
    public func has(_ header: String) -> Bool {
        _storage.firstIndex(where: { $0.key == header }) != nil
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> HTTPHeadersIterator {
        HTTPHeadersIterator(headers: _storage)
    }
}
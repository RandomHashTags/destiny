
public struct HTTPHeaders: HTTPHeadersProtocol, ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = String

    @usableFromInline
    var _storage:[(key: String, value: String)]

    public init(_storage: [(key: String, value: String)] = []) {
        self._storage = _storage
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        _storage = []
        _storage.reserveCapacity(elements.count)
        for (key, value) in elements {
            _storage.append((key, value))
        }
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _storage.reserveCapacity(minimumCapacity)
    }
}

extension HTTPHeaders {
    /// - Complexity: Reading or writing a header value that already exists is O(_n_), while removing a header (writing `nil`) is O(*2n*) if it exists and O(_n_) on average if it doesn't.
    @inlinable
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

    /// - Complexity: O(_n_).
    @inlinable
    public func has(_ header: String) -> Bool {
        _storage.firstIndex(where: { $0.key == header }) != nil
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> Iterator {
        Iterator(headers: _storage)
    }

    public struct Iterator: IteratorProtocol {
        @usableFromInline
        let headers:[(key: String, value: String)]

        @usableFromInline
        var index:UInt16

        @usableFromInline
        let maxIndex:UInt16

        public init(
            headers: [(key: String, value: String)]
        ) {
            self.headers = headers
            index = 0
            maxIndex = UInt16(headers.count)
        }

        @inlinable
        public mutating func next() -> (key: String, value: String)? {
            if self.index == maxIndex {
                return nil
            }
            let (key, value) = headers[Int(self.index)]
            self.index += 1
            return (key, value)
        }
    }
}
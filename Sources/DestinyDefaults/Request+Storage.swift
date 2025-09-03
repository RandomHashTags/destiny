
extension Request {
    public struct Storage: Sendable, ~Copyable {
        @usableFromInline
        var storage:[ObjectIdentifier:Sendable]

        #if Inlinable
        @inlinable
        #endif
        public init(_ storage: [ObjectIdentifier:Sendable]) {
            self.storage = storage
        }

        /// Removes all values from the storage.
        #if Inlinable
        @inlinable
        #endif
        public mutating func clear() {
            storage = [:]
        }

        #if Inlinable
        @inlinable
        #endif
        public subscript<Key: StorageKey>(_ key: Key) -> Key.Value? {
            get {
                guard let v = storage[ObjectIdentifier(Key.self)] as? Value<Key.Value> else { return nil }
                return v.value
            }
            set {
                let key = ObjectIdentifier(Key.self)
                guard let newValue else {
                    storage[key] = nil
                    return
                }
                storage[key] = Value(value: newValue)
            }
        }

        /// - Returns: Whether the key exists in the storage.
        #if Inlinable
        @inlinable
        #endif
        public func contains<Key>(_ key: Key.Type) -> Bool {
            storage.keys.contains(ObjectIdentifier(Key.self))
        }

        /// - Note: Only use if you need it (e.g. required if doing async work from a responder).
        /// - Returns: A copy of self.
        #if Inlinable
        @inlinable
        #endif
        public func copy() -> Self {
            Self(storage)
        }
    }
}

// MARK: StorageKey
extension Request {
    /// Core protocol used to identify values by a key in `Storage`.
    public protocol StorageKey {
        /// The type of the stored value associated with this key.
        associatedtype Value:Sendable
    }
}

// MARK: AnyStorageValue
protocol AnyStorageValue: Sendable {
}

// MARK: Storage.Value
extension Request.Storage {
    @usableFromInline
    struct Value<T: Sendable>: AnyStorageValue {
        @usableFromInline
        var value:T

        @usableFromInline
        init(value: T) {
            self.value = value
        }
    }
}
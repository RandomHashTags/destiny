
/// - Warning: **DOES NOT** GROW!
struct BitSetHeap: Sendable {
    private var _storage:[UInt64]

    init(minimumCapacity: Int) {
        assert(minimumCapacity > 0)
        let buckets = ((minimumCapacity-1) / 64) + 1
        _storage = .init(repeating: 0, count: buckets)
    }

    /// - Complexity: O(1).
    func index(for member: Int) -> (bucket: Int, bit: Int) {
        let (bucket, bit) = (
            member / 64,
            member % 64
        )
        assert(bucket < _storage.count)
        return (bucket, bit)
    }

    /// - Complexity: O(1).
    func contains(_ member: Int) -> Bool {
        let (bucket, bit) = index(for: member)
        return (_storage[bucket] & (UInt64(1) << bit)) != 0
    }

    /// - Complexity: O(1).
    mutating func insert(_ member: Int) {
        let (bucket, bit) = index(for: member)
        _storage[bucket] |= (UInt64(1) << bit)
    }
}
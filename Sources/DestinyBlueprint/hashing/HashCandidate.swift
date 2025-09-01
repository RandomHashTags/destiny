
public struct HashCandidate: Sendable {
    public var seed:UInt64
    public var shift:Int
    public var mask:UInt64
    public var tableSize:Int

    public var finalHashSubtraction = 0

    public init(
        seed: UInt64,
        shift: Int,
        mask: UInt64,
        tableSize: Int
    ) {
        self.seed = seed
        self.shift = shift
        self.mask = mask
        self.tableSize = tableSize
    }

    /// - Complexity: O(1).
    @inlinable
    public func hash(_ key: UInt64) -> Int {
        Int(((key &* seed) >> shift) & mask)
    }
}
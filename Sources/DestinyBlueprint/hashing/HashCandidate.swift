
public struct HashCandidate: Sendable {
    public let multiplier:UInt64
    public let shift:Int
    public let maskBits:Int
    public let tableSize:Int

    public init(
        multiplier: UInt64,
        shift: Int,
        maskBits: Int,
        tableSize: Int
    ) {
        self.multiplier = multiplier
        self.shift = shift
        self.maskBits = maskBits
        self.tableSize = tableSize
    }

    /// - Complexity: O(1).
    @inlinable
    public var mask: UInt64 {
        UInt64((1 << maskBits) - 1)
    }

    /// - Complexity: O(1).
    @inlinable
    public func hash(_ key: UInt64) -> Int {
        Int(((key &* multiplier) >> shift) & mask)
    }
}
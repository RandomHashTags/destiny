
public struct HashCandidate: Sendable {
    public var seed:UInt64
    public var shift:Int
    public var maskBits: Int {
        didSet {
            tableSize = 1 << maskBits
            _mask = UInt64((1 << maskBits) - 1)
        }
    }
    public var tableSize:UInt64

    @usableFromInline
    var _mask:UInt64 = 0

    @usableFromInline
    package var finalHashSubtraction:UInt64 = 0

    public init(
        seed: UInt64,
        shift: Int,
        maskBits: Int,
        _mask: UInt64? = nil
    ) {
        self.seed = seed
        self.shift = shift
        self.maskBits = maskBits
        if maskBits < .max {
            self._mask = _mask ?? UInt64((1 << maskBits) - 1)
        }
        self.tableSize = 1 << maskBits
    }

    /// - Complexity: O(1).
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public var mask: UInt64 {
        _mask
    }

    /// - Complexity: O(1).
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func hash(_ key: UInt64) -> Int {
        Int(((key &* seed) >> shift) & _mask)
    }
}
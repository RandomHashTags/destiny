
#if canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Foundation)
import Foundation
#endif

// TODO: move to own repo?
public protocol PerfectHashable: SIMD where Scalar == UInt8 {
    func extractKey4(positions: InlineArray<64, Int>) -> UInt64
    func extractKey8(positions: InlineArray<64, Int>) -> UInt64
    func extractKey16(positions: InlineArray<64, Int>) -> UInt64
    func extractKey32(positions: InlineArray<64, Int>) -> UInt64
}

// MARK: PerfectHashableItem
public struct PerfectHashableItem<T: PerfectHashable> {
    public let name:String
    public let simd:T

    public init(
        _ name: String,
        _ simd: T
    ) {
        self.name = name
        self.simd = simd
    }
}

// MARK: PerfectHashableEntry
public struct PerfectHashableEntry {
    public let name:String
    public let key:UInt64
}

// MARK: PerfectHashGenerator
public struct PerfectHashGenerator<let entriesCount: Int, T: PerfectHashable> {

    public let entries:InlineArray<entriesCount, PerfectHashableEntry>

    public let multipliers:InlineArray<_, UInt64> = [
        0x9E3779B97F4A7C15, // Golden ratio
        0xC6A4A7935BD1E995, // MurmurHash2
        0xD6E8FEB86659FD93, // Custom multiplier
        0xBF58476D1CE4E5B9, // Another good one
        0x94D049BB133111EB, // FNV-like
        0x517CC1B727220A95, // Random large odd
        0x5851F42D4C957F2D, // Another option
        0x2127599BF4325C37, // More options
        0x3C6EF372FE94F82A,
        0x87C37B91114253D5
    ]

    public init(
        routes: InlineArray<entriesCount, PerfectHashableItem<T>>,
        maxBytes: Int
    ) {
        let positions = Self.findPerfectHashPositions(routes: routes, maxBytes: maxBytes)
        var array = InlineArray<entriesCount, PerfectHashableEntry>(repeating: .init(name: "", key: 0))
        let closure:(T) -> UInt64
        switch maxBytes {
            case 4:  closure = { $0.extractKey4(positions: positions) }
            case 8:  closure = { $0.extractKey8(positions: positions) }
            case 16: closure = { $0.extractKey16(positions: positions) }
            case 32: closure = { $0.extractKey32(positions: positions) }
            default: closure = { $0.extractKey4(positions: positions) }
        }
        for i in 0..<entriesCount {
            let item = routes[i]
            array[i] = .init(name: item.name, key: closure(item.simd))
        }
        entries = array
    }
}

// MARK: Positions
extension PerfectHashGenerator {
    // Attempt to find a set of byte positions that yield a perfect hash
    @inlinable
    public static func findPerfectHashPositions(
        routes: InlineArray<entriesCount, PerfectHashableItem<T>>,
        maxBytes: Int
    ) -> InlineArray<64, Int> {
        var characterCount = InlineArray<64, Set<UInt8>>(repeating: .init())
        let scalarCount = T.scalarCount
        for indice in routes.indices {
            // TODO: pick the last element(s) in the target path (after method and before http version)
            let simd = routes[indice].simd
            for i in 0..<scalarCount {
                let byte = simd[i]
                if byte != 0 {
                    characterCount[i].insert(byte)
                }
            }
        }
        var positions = InlineArray<64, Int>.init(repeating: 0)
        var positionIndex = 0
        var index = -1
        var countAtIndex = 0
        while positionIndex < maxBytes {
            for i in 0..<scalarCount {
                if index == -1 || characterCount[i].count >= countAtIndex {
                    index = i
                    countAtIndex = characterCount[i].count
                }
            }
            if index != -1 {
                positions[positionIndex] = index
                positionIndex += 1
                characterCount[index].removeAll()
                index = -1
                countAtIndex = 0
            } else {
                break
            }
        }
        return positions
    }
}


// MARK: Perfect
extension PerfectHashGenerator {
    @inlinable
    public func findPerfectHashFunction() -> (candidate: HashCandidate, hashTable: [UInt8], verificationKeys: InlineArray<entriesCount, UInt64>)? {
        // try different table sizes (power of 2)
        let minimumMask = Int(ceil(sqrt(Double(entriesCount))))
        for maskBits in minimumMask...8 { // 2, 4, 8, 16, 32, 64, 128, 256 slots
            let tableSize = 1 << maskBits
            if tableSize >= entriesCount {
                // try different shift amounts
                for shift in (64 - maskBits - 4)...(64 - maskBits) {
                    for indice in multipliers.indices {
                        let multiplier = multipliers[indice]
                        let candidate = HashCandidate(
                            multiplier: multiplier,
                            shift: shift,
                            maskBits: maskBits,
                            tableSize: tableSize
                        )
                        if let (hashTable, verificationKeys) = tryHashFunction(candidate) {
                            return (candidate, hashTable, verificationKeys)
                        }
                    }
                }
            }
        }
        return nil
    }

    @inlinable
    public func tryHashFunction(
        _ candidate: HashCandidate
    ) -> (hashTable: [UInt8], verificationKeys: InlineArray<entriesCount, UInt64>)? {
        var hashTable = [UInt8](repeating: 255, count: candidate.tableSize) // 255 = empty slot
        var verificationKeys = InlineArray<entriesCount, UInt64>.init(repeating: 0)
        var usedSlots = Set<Int>()
        usedSlots.reserveCapacity(entriesCount)

        var assigned = [String](repeating: "", count: candidate.tableSize)
        for i in entries.indices {
            let entry = entries[i]
            let key = entry.key
            let hashSlot = candidate.hash(key)

            if usedSlots.contains(hashSlot) { // collision
                #if DEBUG
                //print("\(#function);collision;candidate=\(candidate);\"\(entry.name)\" collides with \"\(assigned[hashSlot])\"")
                #endif
                return nil
            }
            hashTable[hashSlot] = UInt8(i)
            verificationKeys[i] = key
            usedSlots.insert(hashSlot)
            assigned[hashSlot] = entry.name
        }
        return (hashTable, verificationKeys)
    }

    @discardableResult
    @inlinable
    public func generatePerfectHash() -> (
        candidate: HashCandidate,
        hashTable: [UInt8],
        verificationKeys: InlineArray<entriesCount, UInt64>,
        efficiency: Double
    )? {
        guard let (candidate, hashTable, verificationKeys) = findPerfectHashFunction() else { return nil }
        // verify it works
        var allPassed = true
        for i in entries.indices {
            let key = entries[i].key
            let hash = candidate.hash(key)
            let storedIndex = hashTable[hash]
            let storedKey = verificationKeys[Int(storedIndex)]
            if storedIndex == UInt8(i) && storedKey == key {
                // passed
            } else {
                allPassed = false
                return nil
            }
        }
        if allPassed {
            let usedSlots = hashTable.count(where: { $0 != 255 })
            let efficiency = Double(usedSlots) / Double(candidate.tableSize) * 100
            return (candidate, hashTable, verificationKeys, efficiency)
        }
        return nil
    }
}

// MARK: Minimal
extension PerfectHashGenerator {
    // for minimal perfect hash, table size = number of entries
    @inlinable
    public func findMinimalPerfectHash() -> (candidate: HashCandidate, MinimalResult)? {
        for shift in (64 - entriesCount - 4)...(64 - entriesCount) {
            for indice in multipliers.indices {
                let candidate = HashCandidate(
                    multiplier: multipliers[indice],
                    shift: shift,
                    maskBits: entriesCount,
                    tableSize: entriesCount
                )
                if let result = tryMinimalHashFunction(candidate) {
                    return (candidate, result)
                }
            }
        }
        return nil
    }

    @inlinable
    public func tryMinimalHashFunction(
        _ candidate: HashCandidate
    ) -> MinimalResult? {
        var hashTable = InlineArray<entriesCount, UInt8>.init(repeating: 255)
        var verificationKeys = InlineArray<entriesCount, UInt64>.init(repeating: 0)
        var usedSlots = Set<Int>()
        usedSlots.reserveCapacity(entriesCount)

        var assigned = InlineArray<entriesCount, String>.init(repeating: "")
        //var collisions = Set<String>()
        for i in entries.indices {
            let entry = entries[i]
            let key = entry.key
            let hashSlot = candidate.hash(key) % entriesCount

            if usedSlots.contains(hashSlot) { // collision
                //collisions.insert(entry.name)
                //continue
                #if DEBUG
                //print("\(#function);collision;candidate=\(candidate);\"\(entry.name)\" collides with \"\(assigned[hashSlot])\"")
                #endif
                return nil
            }
            hashTable[hashSlot] = UInt8(i)
            verificationKeys[i] = key
            usedSlots.insert(hashSlot)
            assigned[hashSlot] = entry.name
        }
        /*if !collisions.isEmpty {
            return nil
        }*/
        return .init(hashTable: hashTable, verificationKeys: verificationKeys)
    }

    public struct MinimalResult {
        public let hashTable:InlineArray<entriesCount, UInt8>
        public let verificationKeys:InlineArray<entriesCount, UInt64>

        public init(
            hashTable: InlineArray<entriesCount, UInt8>,
            verificationKeys: InlineArray<entriesCount, UInt64>
        ) {
            self.hashTable = hashTable
            self.verificationKeys = verificationKeys
        }
    }
}

// MARK: HashCandidate
public struct HashCandidate {
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
    func hash(_ key: UInt64) -> Int {
        Int(((key &* multiplier) >> shift) & mask)
    }
}

// MARK: SIMD64 extension
extension SIMD64<UInt8>: PerfectHashable {
    @inlinable
    public func extractKey4(positions: InlineArray<64, Int>) -> UInt64 {
        return withUnsafeBytes(of: (self[positions[0]], self[positions[1]], self[positions[2]], self[positions[3]])) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey8(positions: InlineArray<64, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey16(positions: InlineArray<64, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]],
            self[positions[8]],
            self[positions[9]],
            self[positions[10]],
            self[positions[11]],
            self[positions[12]],
            self[positions[13]],
            self[positions[14]],
            self[positions[15]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
    @inlinable
    public func extractKey32(positions: InlineArray<64, Int>) -> UInt64 {
        return withUnsafeBytes(of: (
            self[positions[0]],
            self[positions[1]],
            self[positions[2]],
            self[positions[3]],
            self[positions[4]],
            self[positions[5]],
            self[positions[6]],
            self[positions[7]],
            self[positions[8]],
            self[positions[9]],
            self[positions[10]],
            self[positions[11]],
            self[positions[12]],
            self[positions[13]],
            self[positions[14]],
            self[positions[15]],
            self[positions[16]],
            self[positions[17]],
            self[positions[18]],
            self[positions[19]],
            self[positions[20]],
            self[positions[21]],
            self[positions[22]],
            self[positions[23]],
            self[positions[24]],
            self[positions[25]],
            self[positions[26]],
            self[positions[27]],
            self[positions[28]],
            self[positions[29]],
            self[positions[30]],
            self[positions[31]]
        )) {
            $0.load(as: UInt64.self)
        }
    }
}
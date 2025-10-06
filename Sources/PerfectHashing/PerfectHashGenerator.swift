
import UnwrapArithmeticOperators

// TODO: move to own repo?
public struct PerfectHashGenerator<T: PerfectHashable>: PerfectHashGeneratorProtocol {

    public let entries:[PerfectHashableEntry]
    public let entriesCount:Int
    public let positions:InlineArray<64, Int>

    public init(
        routes: [PerfectHashableItem<T>],
        maxBytes: Int
    ) {
        let positions = Self.findPerfectHashPositions(routes: routes, maxBytes: maxBytes)
        self.init(routes: routes, maxBytes: maxBytes, positions: positions)
    }
    public init(
        routes: [PerfectHashableItem<T>],
        maxBytes: Int,
        positions: InlineArray<64, Int>
    ) {
        let entriesCount = routes.count
        let closure:(T) -> UInt64 = Self.extractKeyClosure(positions: positions, maxBytes: maxBytes)
        var array = [PerfectHashableEntry]()
        array.reserveCapacity(entriesCount)
        for i in 0..<entriesCount {
            let item = routes[i]
            array.append(.init(name: item.name, key: closure(item.simd)))
        }
        entries = array
        self.entriesCount = entriesCount
        self.positions = positions
    }
}

// MARK: Positions
extension PerfectHashGenerator {
    /// - Returns: Route indexes that have the most unique characters.
    #if Inlinable
    @inlinable
    #endif
    public static func findPerfectHashPositions(
        routes: [PerfectHashableItem<T>],
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
                positionIndex +=! 1
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
    #if Inlinable
    @inlinable
    #endif
    public func findPerfectHashFunction<let count: Int>(
        seeds: InlineArray<count, UInt64>
    ) -> (candidate: HashCandidate, hashTable: [UInt8], verificationKeys: [UInt64])? {
        var candidate = HashCandidate(
            seed: .max,
            shift: .max,
            maskBits: .max
        )
        var verificationKeys = [UInt64](repeating: 0, count: entriesCount)
        for maskBits in 1...10 { // 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024 slots
            let tableSize:UInt64 = 1 << maskBits
            if tableSize >= entriesCount {
                candidate.maskBits = maskBits
                var hashTable = [UInt8](repeating: 255, count: Int(tableSize)) // 255 = empty slot
                var found = [(HashCandidate, [UInt8], [UInt64])]()
                for shift in 0...60 {
                    candidate.shift = shift
                    for indice in seeds.indices {
                        candidate.seed = seeds[indice]
                        if tryHashFunction(candidate: candidate, hashTable: &hashTable, verificationKeys: &verificationKeys) {
                            found.append((candidate, [UInt8](hashTable), [UInt64](verificationKeys)))
                        }
                        var mutableSpan = hashTable.mutableSpan
                        mutableSpan.update(repeating: 0)
                    }
                }
                if !found.isEmpty {
                    //print("PerfectHashGenerator;\(#function);found \(found.count) perfect hash(es) of tableSize \(tableSize)")
                    return found.min(by: { $0.0.tableSize < $1.0.tableSize }) ?? found.randomElement()
                }
            }
        }
        return nil
    }

    #if Inlinable
    @inlinable
    #endif
    public func tryHashFunction(
        candidate: HashCandidate,
        hashTable: inout [UInt8],
        verificationKeys: inout [UInt64]
    ) -> Bool {
        var usedSlots = Set<Int>(minimumCapacity: entriesCount)
        //var assigned = [String](repeating: "", count: candidate.tableSize)
        for i in entries.indices {
            let entry = entries[i]
            let key = entry.key
            let hashSlot = candidate.hash(key)
            if hashSlot >= candidate.tableSize {
                return false
            }

            if usedSlots.contains(hashSlot) { // collision
                #if DEBUG
                //print("\(#function);collision;candidate=\(candidate);\"\(entry.name)\" collides with \"\(assigned[hashSlot])\"")
                #endif
                return false
            }
            hashTable[hashSlot] = UInt8(i)
            verificationKeys[i] = key
            usedSlots.insert(hashSlot)
            //assigned[hashSlot] = entry.name
        }
        return true
    }

    @discardableResult
    #if Inlinable
    @inlinable
    #endif
    public func generatePerfectHash<let count: Int>(seeds: InlineArray<count, UInt64>) -> (
        candidate: HashCandidate,
        hashTable: [UInt8],
        verificationKeys: [UInt64],
        efficiency: Double
    )? {
        guard var (candidate, hashTable, verificationKeys) = findPerfectHashFunction(seeds: seeds) else { return nil }
        // verify it works
        for i in entries.indices {
            let key = entries[i].key
            let hash = candidate.hash(key)
            let storedIndex = hashTable[hash]
            let storedKey = verificationKeys[Int(storedIndex)]
            if storedIndex == UInt8(i) && storedKey == key {
                // passed
            } else {
                return nil
            }
        }
        while hashTable.first == 255 {
            hashTable.removeFirst()
            candidate.finalHashSubtraction +=! 1
            candidate.tableSize -=! 1
        }
        while hashTable.last == 255 {
            hashTable.removeLast()
            candidate.tableSize -=! 1
        }
        let usedSlots = hashTable.count(where: { $0 != 255 })
        let efficiency = Double(usedSlots) / Double(candidate.tableSize) * 100
        return (candidate, hashTable, verificationKeys, efficiency)
    }
}

// MARK: Minimal
extension PerfectHashGenerator {
    // for minimal perfect hash, table size = number of entries
    #if Inlinable
    @inlinable
    #endif
    public func findMinimalPerfectHash<let count: Int>(seeds: InlineArray<count, UInt64>) -> (candidate: HashCandidate, result: MinimalResult)? {
        var candidate = HashCandidate(
            seed: .max,
            shift: .max,
            maskBits: entriesCount,
            _mask: UInt64(entriesCount)
        )
        for shift in (64 - entriesCount - 4)...(64 - entriesCount) {
            candidate.shift = shift
            for indice in seeds.indices {
                candidate.seed = seeds[indice]
                if let result = tryMinimalHashFunction(candidate) {
                    return (candidate, result)
                }
            }
        }
        return nil
    }

    #if Inlinable
    @inlinable
    #endif
    public func tryMinimalHashFunction(
        _ candidate: HashCandidate
    ) -> MinimalResult? {
        var hashTable = [UInt8](repeating: 255, count: entriesCount)
        var verificationKeys = [UInt64](repeating: 0, count: entriesCount)
        var usedSlots = Set<Int>()
        usedSlots.reserveCapacity(entriesCount)

        //var assigned = [String](repeating: "", count: entriesCount)
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
            //assigned[hashSlot] = entry.name
        }
        /*if !collisions.isEmpty {
            return nil
        }*/
        return .init(hashTable: hashTable, verificationKeys: verificationKeys)
    }

    public struct MinimalResult {
        public let hashTable:[UInt8]
        public let verificationKeys:[UInt64]

        public init(
            hashTable: [UInt8],
            verificationKeys: [UInt64]
        ) {
            self.hashTable = hashTable
            self.verificationKeys = verificationKeys
        }
    }
}
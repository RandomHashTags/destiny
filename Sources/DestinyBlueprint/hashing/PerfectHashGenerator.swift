
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
    @inlinable
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
    public func findPerfectHashFunction<let count: Int>(
        seeds: InlineArray<count, UInt64>
    ) -> (candidate: HashCandidate, hashTable: [UInt8], verificationKeys: [UInt64])? {
        for maskBits in 1...9 { // 2, 4, 8, 16, 32, 64, 128, 256, 512 slots
            let tableSize:UInt64 = 1 << maskBits
            if tableSize >= entriesCount {
                // try different shift amounts
                for shift in (64 - maskBits - 4)...(64 - maskBits) {
                    for indice in seeds.indices {
                        let candidate = HashCandidate(
                            seed: seeds[indice],
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
    ) -> (hashTable: [UInt8], verificationKeys: [UInt64])? {
        var hashTable = [UInt8](repeating: 255, count: Int(candidate.tableSize)) // 255 = empty slot
        var verificationKeys = [UInt64](repeating: 0, count: entriesCount)
        var usedSlots = Set<Int>()
        usedSlots.reserveCapacity(entriesCount)

        //var assigned = [String](repeating: "", count: candidate.tableSize)
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
            //assigned[hashSlot] = entry.name
        }
        return (hashTable, verificationKeys)
    }

    @discardableResult
    @inlinable
    public func generatePerfectHash<let count: Int>(seeds: InlineArray<count, UInt64>) -> (
        candidate: HashCandidate,
        hashTable: [UInt8],
        verificationKeys: [UInt64],
        efficiency: Double
    )? {
        guard let (candidate, hashTable, verificationKeys) = findPerfectHashFunction(seeds: seeds) else { return nil }
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
    public func findMinimalPerfectHash<let count: Int>(seeds: InlineArray<count, UInt64>) -> (candidate: HashCandidate, result: MinimalResult)? {
        for shift in (64 - entriesCount - 4)...(64 - entriesCount) {
            for indice in seeds.indices {
                let candidate = HashCandidate(
                    seed: seeds[indice],
                    shift: shift,
                    maskBits: entriesCount,
                    tableSize: UInt64(entriesCount)
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
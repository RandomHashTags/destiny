
// MARK: InlineVLArray
/// Inline variable-length array
/// - Warning: This object should not be stored as a property
public struct InlineVLArray<Element>: InlineArrayProtocol, @unchecked Sendable {
    public init(repeating value: Element) {
        fatalError("not implemented")
    }
    
    @inlinable
    public static func create(amount: Int, default: Element, _ closure: (inout Self) throws -> Void) rethrows {
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: amount, { p in
            let _ = p.initialize(repeating: `default`)
            var array = Self(storage: p)
            try closure(&array)
        })
    }

    @inlinable
    public init(storage: UnsafeMutableBufferPointer<Element>) {
        self.storage = storage
    }

    @inlinable public var startIndex:Index { storage.startIndex }
    @inlinable public var endIndex:Index { storage.endIndex }
    @inlinable public var count:Int { storage.count }
    @inlinable public var isEmpty:Bool { storage.isEmpty }
    @inlinable public var indices:Range<Index> { storage.indices }

    public let storage:UnsafeMutableBufferPointer<Element>

    @inlinable
    public borrowing func index(after i: Index) -> Index {
        storage.index(after: i)
    }

    @inlinable
    public borrowing func index(before i: Index) -> Index {
        storage.index(before: i)
    }

    @inlinable
    public func itemAt(index: Index) -> Element {
        storage[index]
    }

    @inlinable
    public mutating func setItemAt(index: Index, element: Element) {
        storage[index] = element
    }

    @inlinable
    public mutating func swapAt(_ i: Index, _ j: Index) {
        let f = storage[i]
        storage[i] = storage[j]
        storage[j] = f
    }
}

extension InlineVLArray where Element == UInt8 {
    @inlinable
    public static func create<T: StringProtocol>(string: T, _ closure: (inout Self) throws -> Void) rethrows {
        let utf8 = string.utf8
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: utf8.count, { p in
            let _ = p.initialize(fromContentsOf: utf8)
            var array = Self(storage: p)
            try closure(&array)
        })
    }
    @inlinable
    public static func create<T: Collection<UInt8>>(collection: T, _ closure: (inout Self) throws -> Void) rethrows {
        let count = collection.count
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: count, { p in
            let _ = p.initialize(fromContentsOf: collection)
            var array = Self(storage: p)
            try closure(&array)
        })
    }
}

// MARK: Join
extension InlineVLArray {
    @inlinable
    public func join<let count: Int>(_ arrays: InlineArray<count, InlineVLArray>, _ closure: (inout Joined) throws -> Void) rethrows {
        try withUnsafeTemporaryAllocation(of: UnsafeMutableBufferPointer<Element>.self, capacity: 1 + count, { pointer in
            pointer.initializeElement(at: 0, to: self.storage)
            for i in arrays.indices {
                pointer.initializeElement(at: 1 + i, to: arrays[i].storage)
            }
            var joined = Joined.init(storage: pointer)
            try closure(&joined)
        })
    }
}

// MARK: Joined
extension InlineVLArray {
    public struct Joined: ~Copyable, @unchecked Sendable {
        public typealias Index = Int

        @usableFromInline let storage:UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<Element>>

        public init(repeating value: Element) {
            fatalError("not implemented")
        }
        @inlinable
        public static func create<let count: Int>(_ elements: InlineArray<count, InlineVLArray<Element>>, closure: (inout Self) throws -> Void) rethrows {
            try withUnsafeTemporaryAllocation(of: UnsafeMutableBufferPointer<Element>.self, capacity: elements.count, { pointer in
                for i in elements.indices {
                    pointer.initializeElement(at: i, to: elements.itemAt(index: i).storage)
                }
                var joined = Self.init(storage: pointer)
                try closure(&joined)
            })
        }

        @inlinable
        public init(storage: UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<Element>>) {
            self.storage = storage
        }
        
        @inlinable public var startIndex:Index { 0 }
        @inlinable public var endIndex:Index { count }

        @inlinable public var count: Int { storage.count }

        @inlinable
        public var capacity: Int {
            var c = 0
            for i in storage.indices {
                c += storage[i].count
            }
            return c
        }

        @inlinable public var isEmpty:Bool { count == 0 }
        @inlinable public var indices:Range<Index> { .init(uncheckedBounds: (0, endIndex)) }

        @inlinable 
        public func index(after i: Index) -> Index {
            i &+ 1
        }

        @inlinable 
        public func index(before i: Index) -> Index {
            i &- 1
        }

        @inlinable 
        public func itemAt(index: Index) -> UnsafeMutableBufferPointer<Element> {
            storage[index]
        }

        @inlinable
        public mutating func setItemAt(index: Index, element: UnsafeMutableBufferPointer<Element>) {
            storage[index] = element
        }

        @inlinable 
        public func elementAt(index: Index) -> Element {
            var previousElements = 0
            for indice in storage.indices {
                let e = storage[indice]
                let currentElements = e.count
                if index < previousElements + currentElements {
                    return e[index - previousElements]
                }
                previousElements += currentElements
            }
            fatalError("out-of-bounds")
        }
        @inlinable
        public mutating func setElementAt(index: Index, element: Element) {
            var previousElements = 0
            for indice in storage.indices {
                let e = storage[indice]
                let currentElements = e.count
                if index < previousElements + currentElements {
                    storage[indice][index - previousElements] = element
                    break
                }
                previousElements += currentElements
            }
        }

        @inlinable
        public func forEachElement(_ yielding: (Element) throws -> Void) rethrows {
            for i in storage.indices {
                let buffer = storage[i]
                for j in buffer.indices {
                    try yielding(buffer[j])
                }
            }
        }

        @inlinable
        public mutating func swapAt(_ i: Index, _ j: Index) {
        }
    }
}
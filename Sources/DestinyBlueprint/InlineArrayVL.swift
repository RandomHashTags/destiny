//
//  InlineArrayVL.swift
//
//
//  Created by Evan Anderson on 5/7/25.
//

// MARK: InlineArrayVL
/// Variable-length inline array
public struct InlineArrayVL<Element>: InlineArrayProtocol, @unchecked Sendable {
    public init(repeating value: Element) {
        fatalError("not implemented")
    }
    
    @inlinable
    public static func create(amount: Int, default: Element, _ closure: (inout Self) throws -> Void) rethrows {
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: amount, { p in
            var array = Self(storage: p)
            for i in array.indices {
                array.setItemAt(index: i, element: `default`)
            }
            try closure(&array)
        })
    }

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

extension InlineArrayVL where Element == UInt8 {
    @inlinable
    public static func create<T: StringProtocol>(string: T, _ closure: (inout Self) throws -> Void) rethrows {
        let count = string.count
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: count, { p in
            var array = Self(storage: p)
            var index = 0
            var i = string.startIndex
            while i < string.endIndex {
                if let char = string[i].asciiValue {
                    array.setItemAt(index: index, element: char)
                    index += 1
                }
                string.formIndex(after: &i)
            }
            try closure(&array)
        })
    }
    @inlinable
    public static func create<T: Collection<UInt8>>(collection: T, _ closure: (inout Self) throws -> Void) rethrows {
        let count = collection.count
        try withUnsafeTemporaryAllocation(of: Element.self, capacity: count, { p in
            var array = Self(storage: p)
            var index = 0
            var i = collection.startIndex
            while i < collection.endIndex {
                array.setItemAt(index: index, element: collection[i])
                index += 1
                collection.formIndex(after: &i)
            }
            try closure(&array)
        })
    }
}

// MARK: Joined
extension InlineArrayVL {
    public func join(_ array: InlineArrayVL) {
    }
}

// MARK: JoinedInlineArrayVL
public struct JoinedInlineArrayVL<let elementsCount: Int, Element: InlineArrayProtocol>: InlineArrayProtocol {
    public typealias Index = Int

    @usableFromInline var storage:InlineArray<elementsCount, Element>

    public init(storage: InlineArray<elementsCount, Element>) {
        self.storage = storage
    }

    public init(repeating value: Element) {
        storage = .init(repeating: value)
    }
    @inlinable public var startIndex:Index { 0 }
    @inlinable public var endIndex:Index { count }

    @inlinable public var count : Int { elementsCount }

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
    public func itemAt(index: Index) -> Element {
        storage[index]
    }

    @inlinable
    public mutating func setItemAt(index: Index, element: Element) {
        storage[index] = element
    }

    @inlinable 
    public func elementAt(index: Index) -> Element.Element {
        var previousElements = 0
        for indice in storage.indices {
            let e = storage[indice]
            let currentElements = e.count
            if index < previousElements + currentElements {
                return e.itemAt(index: index - previousElements)
            }
            previousElements += currentElements
        }
        fatalError("out-of-bounds")
    }
    @inlinable
    public mutating func setElementAt(index: Index, element: Element.Element) {
        var previousElements = 0
        for indice in storage.indices {
            let e = storage[indice]
            let currentElements = e.count
            if index < previousElements + currentElements {
                storage[indice].setItemAt(index: index - previousElements, element: element)
                break
            }
            previousElements += currentElements
        }
    }

    @inlinable
    public mutating func swapAt(_ i: Index, _ j: Index) {
    }
}
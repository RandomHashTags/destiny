//
//  InlineArrayProtocol.swift
//
//
//  Created by Evan Anderson on 4/20/25.
//

public protocol InlineArrayProtocol: Sendable, ~Copyable {
    typealias Index = Int
    associatedtype Element

    static var count: Int { get }

    init(repeating value: Element)

    var startIndex: Index { get }
    var endIndex: Index { get }

    var count: Int { get }
    var isEmpty: Bool { get }
    var indices: Range<Index> { get }

    borrowing func index(after i: Index) -> Index
    borrowing func index(before i: Index) -> Index

    // TODO: remove the following two functions | temporary workaround for borrowing self in a subscript (_read and _modify accessors aren't final)
    func itemAt(index: Index) -> Element 
    mutating func setItemAt(index: Index, element: Element)

    mutating func swapAt(_ i: Index, _ j: Index)
}

// MARK: Extensions
extension Array where Element == UInt8 {
    public init<T: InlineArrayProtocol>(_ inlineArray: T) where T.Index == Index, Element == T.Element {
        self = .init()
        reserveCapacity(inlineArray.count)
        for i in inlineArray.indices {
            append(inlineArray.itemAt(index: i))
        }
    }
}

// MARK Conformances
extension InlineArray: InlineArrayProtocol {
    @inlinable
    public func itemAt(index: Index) -> Element {
        self[index]
    }

    @inlinable
    public mutating func setItemAt(index: Int, element: Element) {
        self[index] = element
    }
}
//
//  InlineArrayProtocol.swift
//
//
//  Created by Evan Anderson on 4/20/25.
//

public protocol InlineArrayProtocol: InlineCollectionProtocol, ~Copyable where Index == Int {
    init(repeating value: Element)
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
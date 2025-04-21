//
//  InlineArrayProtocol.swift
//
//
//  Created by Evan Anderson on 4/20/25.
//

public protocol InlineArrayProtocol : Sendable, ~Copyable {
    associatedtype Index:Strideable
    associatedtype Element

    var startIndex : Index { get }
    var endIndex : Index { get }

    var count : Int { get }
    var indices : Range<Index> { get }

    func itemAt(index: Index) -> Element // TODO: remove | temporary workaround for borrowing self in a subscript (_read and _modify accessors aren't final)
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
extension InlineArray : InlineArrayProtocol {
    @inlinable
    public func itemAt(index: Index) -> Element {
        self[index]
    }
}

public protocol InlineCollectionProtocol: InlineSequenceProtocol, ~Copyable {
    associatedtype Index:Comparable

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
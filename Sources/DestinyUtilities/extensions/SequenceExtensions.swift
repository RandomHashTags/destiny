//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

// MARK: Collection
extension Collection {
    /// - Returns: The element at the given index, if the index is within bounds, otherwise `nil`.
    @usableFromInline
    package func get(_ index: Index) -> Element? {
        return index < endIndex && index >= startIndex ? self[index] : nil
    }
}

// MARK: Array
extension Array where Element == SIMD64<UInt8> {
    // TODO: finish
}
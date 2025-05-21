
// MARK: Collection
extension Collection {
    /// - Returns: The element at the given index, if the index is within bounds, otherwise `nil`.
    @usableFromInline
    package func get(_ index: Index) -> Element? {
        return index < endIndex && index >= startIndex ? self[index] : nil
    }

    @usableFromInline
    package func getPositive(_ index: Index) -> Element? {
        return index < endIndex ? self[index] : nil
    }
}

// MARK: Array
extension Array where Element == SIMD64<UInt8> {
    // TODO: finish
}
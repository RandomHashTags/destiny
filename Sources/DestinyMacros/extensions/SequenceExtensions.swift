
// MARK: Collection
extension Collection {
    /// - Returns: Element at the given index, if the index is less than the `endIndex`, otherwise `nil`.
    func getPositive(_ index: Index) -> Element? {
        return index < endIndex ? self[index] : nil
    }
}
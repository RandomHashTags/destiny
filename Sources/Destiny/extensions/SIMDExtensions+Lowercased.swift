
extension SIMD64<UInt8> {
    /// - Returns: A UTF-8 lowercased version of `self`.
    /// - Complexity: O(1).
    public func lowercased() -> Self {
        var upperCase = self .>= 65
        upperCase .&= self .<= 90

        var addition = Self.zero
        addition.replace(with: 32, where: upperCase) // TODO: use a SIMD blend operation (no existing standard Swift operation)
        return self &+ addition
    }
}
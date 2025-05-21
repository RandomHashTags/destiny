
extension String {
    @inlinable
    public mutating func append<let count: Int>(_ array: InlineArray<count, UInt8>) {
        for i in array.indices {
            let char = array[i]
            if char == 0 {
                break
            }
            self.append(Character(Unicode.Scalar(char)))
        }
    }

    @inlinable
    public func inlineVLArray(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
        try InlineVLArray<UInt8>.create(string: self, closure)
    }
}
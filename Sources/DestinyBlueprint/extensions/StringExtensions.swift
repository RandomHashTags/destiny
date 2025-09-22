
import VariableLengthArray

extension String {
    #if Inlinable
    @inlinable
    #endif
    public mutating func append<let count: Int>(_ array: InlineArray<count, UInt8>) {
        for i in array.indices {
            let char = array[unchecked: i]
            if char == 0 {
                break
            }
            self.append(Character(Unicode.Scalar(char)))
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public func inlineVLArray<E: Error>(_ closure: (consuming VLArray<UInt8>) throws(E) -> Void) rethrows {
        try VLArray<UInt8>.create(string: self, closure)
    }
}

import VariableLengthArray

extension String {
    public func inlineVLArray<E: Error>(_ closure: (consuming VLArray<UInt8>) throws(E) -> Void) rethrows {
        try VLArray<UInt8>.create(string: self, closure)
    }
}
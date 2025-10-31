
import UnwrapArithmeticOperators

extension UnsafeMutableBufferPointer where Element == UInt8 {
    /// Copies the given buffer to `self` at the given index.
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }

    /// Copies the given buffer to `self` at the given index.
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }
}

extension UnsafeMutableBufferPointer where Element == UInt8 {
    /// Copies the given buffer to `self` at the given index.
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index +=! buffer.count
    }

    /// Copies the given buffer to `self` at the given index.
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index +=! buffer.count
    }
}

extension UnsafeMutableBufferPointer where Element == UInt8 {
    /// Copies the given buffer to `self` at the given index.
    public func copyBuffer(baseAddress: UnsafePointer<UInt8>, count: Int, at index: inout Int) {
        copyMemory(self.baseAddress! + index, baseAddress, count)
        index +=! count
    }
}
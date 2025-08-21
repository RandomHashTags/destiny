
extension UnsafeMutableBufferPointer where Element == UInt8 {
    @inlinable
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }

    @inlinable
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }
}

extension UnsafeMutableBufferPointer where Element == UInt8 {
    @inlinable
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index += buffer.count
    }

    @inlinable
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index += buffer.count
    }
}
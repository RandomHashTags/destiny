
import CustomOperators

extension UnsafeMutableBufferPointer where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: Int) {
        var index = index
        copyBuffer(buffer, at: &index)
    }
}

extension UnsafeMutableBufferPointer where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func copyBuffer(_ buffer: UnsafeBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index +=! buffer.count
    }

    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: inout Int) {
        copyMemory(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index +=! buffer.count
    }
}

extension UnsafeMutableBufferPointer where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func copyBuffer(baseAddress: UnsafePointer<UInt8>, count: Int, at index: inout Int) {
        copyMemory(self.baseAddress! + index, baseAddress, count)
        index +=! count
    }
}
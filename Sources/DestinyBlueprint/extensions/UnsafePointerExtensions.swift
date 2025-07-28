
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import SwiftGlibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

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
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        memcpy(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index += buffer.count
        #else
        buffer.forEach {
            self[index] = $0
            index += 1
        }
        #endif
    }

    @inlinable
    public func copyBuffer(_ buffer: UnsafeMutableBufferPointer<Element>, at index: inout Int) {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        memcpy(baseAddress! + index, buffer.baseAddress!, buffer.count)
        index += buffer.count
        #else
        buffer.forEach {
            self[index] = $0
            index += 1
        }
        #endif
    }
}
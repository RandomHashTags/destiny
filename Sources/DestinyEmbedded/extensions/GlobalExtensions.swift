
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

/// Copies a number of bytes from the source pointer to the destination pointer.
/// - Parameters:
///   - __dest: Destination pointer.
///   - __src: Source pointer.
///   - __n: Number of bytes to copy.
#if Inlinable
@inlinable
#endif
#if InlineAlways
@inline(__always)
#endif
package func copyMemory(
    _ __dest: UnsafeMutableRawPointer,
    _ __src: UnsafeRawPointer,
    _ __n: Int
) {
    #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
    memcpy(__dest, __src, __n)
    #else
    __dest.copyMemory(from: __src, byteCount: __n)
    #endif
}
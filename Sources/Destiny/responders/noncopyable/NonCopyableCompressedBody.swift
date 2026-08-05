
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

public struct NonCopyableCompressedBody<let count: Int>: Sendable {
    let bytes:[count of UInt8]

    public func iovec(_ closure: (iovec) -> Void) {
        bytes.span.withUnsafeBufferPointer {
            closure(.init(iov_base: .init(mutating: $0.baseAddress), iov_len: $0.count))
        }
    }
}
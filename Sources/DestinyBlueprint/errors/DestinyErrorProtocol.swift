
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

public protocol DestinyErrorProtocol: Equatable, Error {
    var identifier: String { get }
    var reason: String { get }

    init(identifier: String, reason: String)
}

extension DestinyErrorProtocol {
    @usableFromInline
    static func cError(_ identifier: String) -> Self {
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        return Self(identifier: identifier, reason: String(cString: strerror(errno)) + " (errno=\(errno))")
        #else
        return Self(identifier: identifier, reason: "unspecified")
        #endif
    }
}

#if canImport(Foundation)
import Foundation
#elseif canImport(Glibc)
import Glibc
#endif

public protocol DestinyErrorProtocol: Error {
    var identifier: String { get }
    var reason: String { get }

    init(identifier: String, reason: String)
}

extension DestinyErrorProtocol {
    @usableFromInline
    static func cError(_ identifier: String) -> Self {
        #if canImport(Foundation)
        return Self(identifier: identifier, reason: String(cString: strerror(errno)) + " (errno=\(errno))")
        #elseif canImport(Glibc)
        return Self(identifier: identifier, reason: "unspecified (errno=\(errno))")
        #else
        return Self(identifier: identifier, reason: "unspecified")
        #endif
    }
}

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

public protocol SocketAcceptor: Sendable, ~Copyable {
    /// - Returns: The file descriptor.
    func acceptFunction(noTCPDelay: Bool) -> @Sendable (Int32?) throws -> Int32?
}

extension SocketAcceptor {
    @inlinable
    public func acceptFunction(noTCPDelay: Bool) -> @Sendable (Int32?) throws -> Int32? {
        noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
    }

    @inlinable
    @Sendable
    static func acceptClient(server: Int32?) throws -> Int32? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = withUnsafeMutablePointer(to: &addr, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { accept(serverFD, $0, &len) }) })
        if client == -1 {
            if server == nil {
                return nil
            }
            throw SocketError.acceptFailed()
        }
        return client
    }

    @inlinable
    @Sendable
    static func acceptClientNoTCPDelay(server: Int32?) throws -> Int32? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            if server == nil {
                return nil
            }
            throw SocketError.acceptFailed()
        }
        var d:Int32 = 1
        setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
        return client
    }
}
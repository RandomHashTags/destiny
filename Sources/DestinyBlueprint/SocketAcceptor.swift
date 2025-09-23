
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

/// Types conforming to this protocol can accept file descriptors.
public protocol SocketAcceptor: Sendable, ~Copyable {
    /// - Returns: The file descriptor.
    func acceptFunction(
        noTCPDelay: Bool
    ) -> @Sendable (Int32?) throws(SocketError) -> Int32?
}

extension SocketAcceptor {
    #if Inlinable
    @inlinable
    #endif
    public func acceptFunction(noTCPDelay: Bool) -> @Sendable (Int32?) throws(SocketError) -> Int32? {
        noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
    }

    #if Inlinable
    @inlinable
    #endif
    @Sendable
    static func acceptClient(server: Int32?) throws(SocketError) -> Int32? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = withUnsafeMutablePointer(to: &addr, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { accept(serverFD, $0, &len) }) })
        if client == -1 {
            if server == nil {
                return nil
            }
            throw .acceptFailed(errno: cError())
        }
        return client
    }

    #if Inlinable
    @inlinable
    #endif
    @Sendable
    static func acceptClientNoTCPDelay(server: Int32?) throws(SocketError) -> Int32? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = accept(serverFD, withUnsafeMutablePointer(to: &addr) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { $0 } }, &len)
        if client == -1 {
            if server == nil {
                return nil
            }
            throw .acceptFailed(errno: cError())
        }
        var d:Int32 = 1
        setsockopt(client, Int32(IPPROTO_TCP), TCP_NODELAY, &d, socklen_t(MemoryLayout<Int32>.size))
        return client
    }
}
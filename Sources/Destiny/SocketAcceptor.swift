
#if canImport(Android)
import Android
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WinSDK)
import WinSDK
#endif

public protocol SocketAcceptor: Sendable {
}

extension SocketAcceptor {
    @inlinable
    public func acceptFunction(noTCPDelay: Bool) -> @Sendable (Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        noTCPDelay ? Self.acceptClientNoTCPDelay : Self.acceptClient
    }

    @inlinable
    @Sendable
    static func acceptClient(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
        guard let serverFD = server else { return nil }
        var addr = sockaddr_in(), len = socklen_t(MemoryLayout<sockaddr_in>.size)
        let client = withUnsafeMutablePointer(to: &addr, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1, { accept(serverFD, $0, &len) }) })
        if client == -1 {
            if server == nil {
                return nil
            }
            throw SocketError.acceptFailed()
        }
        return (client, .now)
    }
    @inlinable
    @Sendable
    static func acceptClientNoTCPDelay(server: Int32?) throws -> (fileDescriptor: Int32, instant: ContinuousClock.Instant)? {
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
        return (client, .now)
    }
}
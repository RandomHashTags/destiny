
import DestinyBlueprint

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

extension Data: StaticRouteResponderProtocol {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        try withUnsafeBytes {
            try socket.writeBuffer($0.baseAddress!, length: count)
        }
    }
}
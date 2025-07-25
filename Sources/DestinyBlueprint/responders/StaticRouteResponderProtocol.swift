
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, HTTPSocketWritable {
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {}
extension StaticString: StaticRouteResponderProtocol {}

extension AsyncStream where Element: HTTPSocketWritable {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        for await value in self {
            try await value.write(to: socket)
        }
    }
}

#if canImport(FoundationEssentials) || canImport(Foundation)

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

extension Data: StaticRouteResponderProtocol {
    @inlinable
    public func write<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try withUnsafeBytes {
            try socket.writeBuffer($0.baseAddress!, length: count)
        }
    }
}

#endif

/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol {
    /// Writes a response to a socket.
    @inlinable
    func respond<Socket: HTTPSocketProtocol & ~Copyable>(
        to socket: borrowing Socket
    ) async throws
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {
    @inlinable
    public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try utf8.withContiguousStorageIfAvailable {
            try socket.writeBuffer($0.baseAddress!, length: $0.count)
        }
    }
}

extension StaticString: StaticRouteResponderProtocol {
    @inlinable
    public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        var err:(any Error)? = nil
        withUTF8Buffer {
            do {
                try socket.writeBuffer($0.baseAddress!, length: $0.count)
            } catch {
                err = error
            }
        }
        if let err {
            throw err
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
    public func respond<T: HTTPSocketProtocol & ~Copyable>(to socket: borrowing T) async throws {
        try withUnsafeBytes {
            try socket.writeBuffer($0.baseAddress!, length: count)
        }
    }
}

#endif
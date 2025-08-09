
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, HTTPSocketWritable, ~Copyable {
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {}
extension StaticString: StaticRouteResponderProtocol {}
extension [UInt8]: StaticRouteResponderProtocol {}

extension AsyncStream where Element: HTTPSocketWritable {
    @inlinable
    public func write(
        to socket: borrowing some HTTPSocketProtocol & ~Copyable
    ) async throws(SocketError) {
        for await value in self {
            try value.write(to: socket)
        }
    }
}
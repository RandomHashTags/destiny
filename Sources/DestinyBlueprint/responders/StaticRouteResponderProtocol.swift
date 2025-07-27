
/// Core Static Route Responder protocol that handles requests to static routes.
public protocol StaticRouteResponderProtocol: RouteResponderProtocol, HTTPSocketWritable, ~Copyable {
}

// MARK: Default conformances
extension String: StaticRouteResponderProtocol {}
extension StaticString: StaticRouteResponderProtocol {}

extension AsyncStream where Element: HTTPSocketWritable {
    @inlinable
    public func write(to socket: borrowing some HTTPSocketProtocol & ~Copyable) async throws {
        for await value in self {
            try await value.write(to: socket)
        }
    }
}

import DestinyBlueprint

public final class RouteGroupStorage: MutableRouteGroupStorageProtocol, @unchecked Sendable {
    @usableFromInline
    var groups:[any RouteGroupProtocol]

    public init(_ groups: [any RouteGroupProtocol]) {
        self.groups = groups
    }
}

// MARK: Respond
extension RouteGroupStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        for group in groups {
            if try await group.respond(router: router, socket: socket, request: &request) {
                return true
            }
        }
        return false
    }
}
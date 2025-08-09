
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
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) throws(ResponderError) -> Bool {
        for group in groups {
            if try group.respond(router: router, socket: socket, request: &request) {
                return true
            }
        }
        return false
    }
}
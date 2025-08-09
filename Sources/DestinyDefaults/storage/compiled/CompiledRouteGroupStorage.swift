
import DestinyBlueprint

public struct CompiledRouteGroupStorage<each RouteGroup: RouteGroupProtocol>: RouteGroupStorageProtocol {
    public let groups:(repeat each RouteGroup)

    public init(_ groups: (repeat each RouteGroup)) {
        self.groups = groups
    }
}

// MARK: Respond
extension CompiledRouteGroupStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        for group in repeat each groups {
            if try await group.respond(router: router, socket: socket, request: &request) {
                return true
            }
        }
        return false
    }
}
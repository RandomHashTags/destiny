
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
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        for group in repeat each groups {
            if try group.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
                return true
            }
        }
        return false
    }
}
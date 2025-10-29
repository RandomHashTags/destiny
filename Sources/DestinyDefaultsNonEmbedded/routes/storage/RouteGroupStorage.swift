
#if MutableRouter

import DestinyBlueprint

public final class RouteGroupStorage: @unchecked Sendable { // TODO: avoid existentials / support embedded
    @usableFromInline
    var groups:[any ResponderStorageProtocol]

    public init(_ groups: [any ResponderStorageProtocol] = []) {
        self.groups = groups
    }
}

// MARK: Respond
extension RouteGroupStorage {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        for group in groups {
            if try group.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
                return true
            }
        }
        return false
    }
}

// MARK: Conformances
extension RouteGroupStorage: MutableRouteGroupStorageProtocol {}

#endif
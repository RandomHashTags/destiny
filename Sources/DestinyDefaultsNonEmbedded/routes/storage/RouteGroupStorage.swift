
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
    /// Responds to a socket.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Returns: Whether or not a response was sent.
    /// - Throws: `ResponderError`
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
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

#endif
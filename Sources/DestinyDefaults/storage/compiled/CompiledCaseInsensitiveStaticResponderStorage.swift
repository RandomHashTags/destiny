
import DestinyBlueprint

/// Default immutable storage that handles case insensitive static routes.
public struct CompiledCaseInsensitiveStaticResponderStorage<each ConcreteRoute: CompiledStaticResponderStorageRouteProtocol>: StaticResponderStorageProtocol {
    public let routes:(repeat each ConcreteRoute)

    public init(_ routes: (repeat each ConcreteRoute)) {
        self.routes = routes
    }

    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine = request.startLineLowercased()
        for route in repeat each routes {
            if route.path == startLine {
                try router.respondStatically(socket: socket, request: &request, responder: route.responder, completionHandler: completionHandler)
                return true
            }
        }
        return false
    }
}
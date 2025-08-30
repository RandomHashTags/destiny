
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
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine:SIMD64<UInt8>
        do throws(SocketError) {
            startLine = try request.startLineLowercased()
        } catch {
            throw .socketError(error)
        }
        for route in repeat each routes {
            if route.path == startLine {
                try router.respond(socket: socket, request: &request, responder: route.responder, completionHandler: completionHandler)
                return true
            }
        }
        return false
    }
}
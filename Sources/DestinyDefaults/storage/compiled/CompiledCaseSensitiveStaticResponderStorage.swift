
import DestinyBlueprint

/// Default immutable storage that handles case sensitive static routes.
public struct CompiledCaseSensitiveStaticResponderStorage<each ConcreteRoute: CompiledStaticResponderStorageRouteProtocol>: StaticResponderStorageProtocol {
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
        let startLine = request.startLine
        for route in repeat each routes {
            if route.path == startLine {
                try router.respondStatically(socket: socket, request: &request, responder: route.responder, completionHandler: completionHandler)
                return true
            }
        }
        return false
    }
}

public protocol CompiledStaticResponderStorageRouteProtocol: Sendable, ~Copyable {
    associatedtype ConcreteResponder:StaticRouteResponderProtocol

    var path: DestinyRoutePathType { get }
    var responder: ConcreteResponder { get }
}
public struct CompiledStaticResponderStorageRoute<ConcreteResponder: StaticRouteResponderProtocol>: CompiledStaticResponderStorageRouteProtocol {
    public let path:DestinyRoutePathType
    public let responder:ConcreteResponder

    public init(path: DestinyRoutePathType, responder: ConcreteResponder) {
        self.path = path
        self.responder = responder
    }
}
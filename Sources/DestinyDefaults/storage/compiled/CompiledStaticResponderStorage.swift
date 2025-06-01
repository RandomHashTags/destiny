
import DestinyBlueprint

/// Default immutable storage that handles static routes.
public struct CompiledStaticResponderStorage<each ConcreteRoute: CompiledStaticResponderStorageRouteProtocol>: StaticResponderStorageProtocol {
    public let routes:(repeat each ConcreteRoute)

    public init(_ routes: (repeat each ConcreteRoute)) {
        self.routes = routes
    }

    public var debugDescription: String {
        var s = "CompiledStaticResponderStorage(\n("
        for route in repeat each routes {
            s += "\n" + route.debugDescription + ","
        }
        if s.utf8.span.count != 33 { // was modified
            s.removeLast()
        }
        return s + "\n)\n)"
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        for route in repeat each routes {
            if route.path == startLine {
                try await router.respondStatically(socket: socket, responder: route.responder)
                return true
            }
        }
        return false
    }
}

public protocol CompiledStaticResponderStorageRouteProtocol: CustomDebugStringConvertible, Sendable {
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

    public var debugDescription: String {
        """
        CompiledStaticResponderStorageRoute<\(ConcreteResponder.self)>(
            path: \(path.debugDescription),
            responder: \(responder.debugDescription)
        )
        """
    }
}
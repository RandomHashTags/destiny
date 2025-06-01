
import DestinyBlueprint

/// Default immutable storage that handles dynamic routes.
public struct CompiledDynamicResponderStorage<each ConcreteRoute: CompiledDynamicResponderStorageRouteProtocol>: DynamicResponderStorageProtocol {
    public let routes:(repeat each ConcreteRoute)

    public init(_ routes: (repeat each ConcreteRoute)) {
        self.routes = routes
    }

    public var debugDescription: String {
        var s = "CompiledDynamicResponderStorage(\n("
        for route in repeat each routes {
            s += "\n" + route.debugDescription + ","
        }
        return s + "\n)\n)"
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool {
        for route in repeat each routes {
            if route.path == request.startLine { // parameterless
                try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: route.responder)
                return true
            } else { // parameterized and catchall
                var found = true
                loop: for i in 0..<route.responder.pathComponentsCount {
                    let path = route.responder.pathComponent(at: i)
                    switch path {
                    case .catchall:
                        break loop
                    case .literal(let l):
                        if l != request.path(at: i) {
                            found = false
                            break loop
                        }
                    case .parameter:
                        break
                    }
                }
                if found {
                    try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: route.responder)
                    return true
                }
            }
        }
        return false
    }
}

public protocol CompiledDynamicResponderStorageRouteProtocol: CustomDebugStringConvertible, Sendable {
    associatedtype ConcreteResponder:DynamicRouteResponderProtocol

    var path: DestinyRoutePathType { get }
    var responder: ConcreteResponder { get }
}
public struct CompiledDynamicResponderStorageRoute<ConcreteResponder: DynamicRouteResponderProtocol>: CompiledDynamicResponderStorageRouteProtocol {
    public let path:DestinyRoutePathType
    public let responder:ConcreteResponder

    public init(path: DestinyRoutePathType, responder: ConcreteResponder) {
        self.path = path
        self.responder = responder
    }

    public var debugDescription: String {
        """
        CompiledDynamicResponderStorageRoute<\(ConcreteResponder.self)>(
            path: \(path.debugDescription),
            responder: \(responder.debugDescription)
        )
        """
    }
}
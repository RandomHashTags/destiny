
import DestinyBlueprint

/// Default immutable storage that handles dynamic routes.
public struct CompiledDynamicResponderStorage<each ConcreteRoute: CompiledDynamicResponderStorageRouteProtocol>: DynamicResponderStorageProtocol {
    public let routes:(repeat each ConcreteRoute)

    public init(_ routes: (repeat each ConcreteRoute)) {
        self.routes = routes
    }

    @inlinable
    public func respond(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws -> Bool {
        let requestPathCount = request.pathCount
        for route in repeat each routes {
            if route.path == request.startLine { // parameterless
                try await router.respondDynamically(socket: socket, request: &request, responder: route.responder)
                return true
            } else { // parameterized and catchall
                let pathComponentsCount = route.responder.pathComponentsCount
                var found = true
                var lastIsCatchall = false
                var lastIsParameter = false
                loop: for i in 0..<pathComponentsCount {
                    let path = route.responder.pathComponent(at: i)
                    switch path {
                    case .catchall:
                        lastIsCatchall = true
                        lastIsParameter = false
                        break loop
                    case .literal(let l):
                        lastIsCatchall = false
                        lastIsParameter = false
                        if requestPathCount <= i || l != request.path(at: i) {
                            found = false
                            break loop
                        }
                    case .parameter:
                        lastIsCatchall = false
                        lastIsParameter = true
                    }
                }
                if found && (lastIsCatchall || lastIsParameter && requestPathCount == pathComponentsCount) {
                    try await router.respondDynamically(socket: socket, request: &request, responder: route.responder)
                    return true
                }
            }
        }
        return false
    }
}

public protocol CompiledDynamicResponderStorageRouteProtocol: Sendable {
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
}
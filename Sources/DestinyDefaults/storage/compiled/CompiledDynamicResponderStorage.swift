
import DestinyBlueprint

/// Default immutable storage that handles dynamic routes.
public struct CompiledDynamicResponderStorage<each ConcreteRoute: CompiledDynamicResponderStorageRouteProtocol>: DynamicResponderStorageProtocol {
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
        let requestPathCount:Int
        let requestStartLine:SIMD64<UInt8>
        do throws(SocketError) {
            requestPathCount = try request.pathCount()
            requestStartLine = try request.startLine()
        } catch {
            throw .socketError(error)
        }
        for route in repeat each routes {
            if route.path == requestStartLine { // parameterless
                try router.respondDynamically(socket: socket, request: &request, responder: route.responder, completionHandler: completionHandler)
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
                        if requestPathCount <= i {
                            found = false
                            break loop
                        } else {
                            do throws(SocketError) {
                                let pathAtIndex = try request.path(at: i)
                                if l != pathAtIndex {
                                    found = false
                                    break loop
                                }
                            } catch {
                                throw .socketError(error)
                            }
                        }
                    case .parameter:
                        lastIsCatchall = false
                        lastIsParameter = true
                    }
                }
                if found && (lastIsCatchall || lastIsParameter && requestPathCount == pathComponentsCount) {
                    try router.respondDynamically(socket: socket, request: &request, responder: route.responder, completionHandler: completionHandler)
                    return true
                }
            }
        }
        return false
    }
}

public protocol CompiledDynamicResponderStorageRouteProtocol: Sendable, ~Copyable {
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

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
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        let startLine:SIMD64<UInt8>
        do throws(SocketError) {
            startLine = try request.startLine()
        } catch {
            throw .socketError(error)
        }
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

    var path: SIMD64<UInt8> { get }
    var responder: ConcreteResponder { get }
}
public struct CompiledStaticResponderStorageRoute<ConcreteResponder: StaticRouteResponderProtocol>: CompiledStaticResponderStorageRouteProtocol {
    public let path:SIMD64<UInt8>
    public let responder:ConcreteResponder

    public init(path: SIMD64<UInt8>, responder: ConcreteResponder) {
        self.path = path
        self.responder = responder
    }
}
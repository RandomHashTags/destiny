
import DestinyBlueprint

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage<each Responder: CompiledStaticResponderStorageRouteProtocol>: StaticResponderStorageProtocol {
    public let values:(repeat each Responder)

    public init(_ values: (repeat each Responder)) {
        self.values = values
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        for value in repeat each values {
            if value.path == startLine {
                try await router.respondStatically(socket: socket, responder: value.responder)
                return true
            }
        }
        return false
    }

    public var debugDescription: String {
        var s = "CompiledStaticResponderStorage(("
        for value in repeat each values {
            s += "\n" + value.debugDescription + ","
        }
        if s.utf8.span.count != 32 { // was modified
            s.removeLast()
        }
        return s + "\n))"
    }
}

public protocol CompiledStaticResponderStorageRouteProtocol: CustomDebugStringConvertible, Sendable {
    associatedtype T:StaticRouteResponderProtocol

    var path: DestinyRoutePathType { get }
    var responder: T { get }
}
public struct CompiledStaticResponderStorageRoute<T: StaticRouteResponderProtocol>: CompiledStaticResponderStorageRouteProtocol {
    public let path:DestinyRoutePathType
    public let responder:T

    public init(path: DestinyRoutePathType, responder: T) {
        self.path = path
        self.responder = responder
    }

    public var debugDescription: String {
        """
        CompiledStaticResponderStorageRoute<\(T.self)>(
            path: \(path.debugDescription),
            responder: \(responder.debugDescription)
        )
        """
    }
}
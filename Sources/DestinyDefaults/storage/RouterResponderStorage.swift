
import DestinyBlueprint

/// Default mutable storage that handles conditional, dynamic and static routes.
public struct RouterResponderStorage<
        ConcreteStaticResponderStorage: StaticResponderStorageProtocol,
        ConcreteDynamicResponderStorage: DynamicResponderStorageProtocol
    >: RouterResponderStorageProtocol {
    public var `static`:ConcreteStaticResponderStorage
    public var dynamic:ConcreteDynamicResponderStorage
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    @inlinable
    public init(
        static: ConcreteStaticResponderStorage,
        dynamic: ConcreteDynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }

    @inlinable
    public func respond<Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool {
        if try await respondStatically(router: router, socket: socket, startLine: request.startLine) {
            return true
        }
        if try await respondDynamically(router: router, received: received, loaded: loaded, socket: socket, request: &request) {
            return true
        }
        if let responder = conditional[request.startLine] {
            return try await responder.respond(router: router, received: received, loaded: loaded, socket: socket, request: &request)
        }
        return false
    }
}

extension RouterResponderStorage {
    @inlinable
    public func respondStatically(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool {
        return try await `static`.respond(router: router, socket: socket, startLine: startLine)
    }

    @inlinable
    public func respondDynamically<Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing some HTTPRouterProtocol & ~Copyable,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest,
    ) async throws -> Bool {
        return try await dynamic.respond(router: router, received: received, loaded: loaded, socket: socket, request: &request)
    }
}
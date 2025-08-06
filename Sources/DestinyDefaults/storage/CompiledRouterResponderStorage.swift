
import DestinyBlueprint

/// Default immutable storage that handles conditional, dynamic and static routes.
public struct CompiledRouterResponderStorage<
        StaticResponderStorage: StaticResponderStorageProtocol,
        DynamicResponderStorage: DynamicResponderStorageProtocol
    >: RouterResponderStorageProtocol {
    public let `static`:StaticResponderStorage
    public let dynamic:DynamicResponderStorage
    public let conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    @inlinable
    public init(
        static: StaticResponderStorage,
        dynamic: DynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }
}

// MARK: Respond
extension CompiledRouterResponderStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        if try await respondStatically(router: router, socket: socket, startLine: request.startLine) {
            return true
        }
        if try await respondDynamically(router: router, socket: socket, request: &request) {
            return true
        }
        if let responder = conditional[request.startLine] {
            return try await responder.respond(router: router, socket: socket, request: &request)
        }
        return false
    }

    @inlinable
    public func respondStatically(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        startLine: SIMD64<UInt8>
    ) async throws(ResponderError) -> Bool {
        return try await `static`.respond(router: router, socket: socket, startLine: startLine)
    }

    @inlinable
    public func respondDynamically(
        router: some HTTPRouterProtocol,
        socket: borrowing some HTTPSocketProtocol & ~Copyable,
        request: inout some HTTPRequestProtocol & ~Copyable,
    ) async throws(ResponderError) -> Bool {
        return try await dynamic.respond(router: router, socket: socket, request: &request)
    }
}

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
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) async throws(ResponderError) -> Bool {
        if try respondStatically(router: router, socket: socket, startLine: request.startLine) {
            return true
        }
        if try respondDynamically(router: router, socket: socket, request: &request) {
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
        socket: Int32,
        startLine: SIMD64<UInt8>
    ) throws(ResponderError) -> Bool {
        return try `static`.respond(router: router, socket: socket, startLine: startLine)
    }

    @inlinable
    public func respondDynamically(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
    ) throws(ResponderError) -> Bool {
        return try dynamic.respond(router: router, socket: socket, request: &request)
    }
}
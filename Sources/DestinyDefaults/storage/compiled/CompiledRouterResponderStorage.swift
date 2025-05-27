
/*
import DestinyBlueprint

public struct CompiledRouterResponderStorage<
        let staticStringsCount: Int,
        let stringsCount: Int,
        let stringsWithDateHeaderCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: RouterResponderStorageProtocol {
    public let `static`:CompiledStaticResponderStorage<staticStringsCount, stringsCount, stringsWithDateHeaderCount, uint8ArraysCount, uint16ArraysCount>
    public let dynamic:DynamicResponderStorage
    public let conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

    @inlinable
    public init(
        static: CompiledStaticResponderStorage<staticStringsCount, stringsCount, stringsWithDateHeaderCount, uint8ArraysCount, uint16ArraysCount>,
        dynamic: DynamicResponderStorage,
        conditional: [DestinyRoutePathType:any ConditionalRouteResponderProtocol]
    ) {
        self.static = `static`
        self.dynamic = dynamic
        self.conditional = conditional
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any HTTPRequestProtocol
    ) async throws -> Bool {
        if try await respondStatically(router: router, socket: socket, startLine: request.startLine) {
            return true
        }
        if let responder = dynamic.responder(for: &request) {
            try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
            return true
        }
        if let responder = conditional[request.startLine] {
            return try await responder.respond(router: router, received: received, loaded: loaded, socket: socket, request: &request)
        }
        return false
    }
}

extension CompiledRouterResponderStorage {
    @inlinable
    public func respondStatically<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        socket: borrowing Socket,
        startLine: SIMD64<UInt8>
    ) async throws -> Bool {
        return try await `static`.respond(router: router, socket: socket, startLine: startLine)
    }

    @inlinable
    public func respondDynamically<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any HTTPRequestProtocol,
    ) async throws -> Bool {
        guard let responder = dynamic.responder(for: &request) else { return false }
        try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: responder)
        return true
    }
}*/
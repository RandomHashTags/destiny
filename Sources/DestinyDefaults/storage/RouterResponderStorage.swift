//
//  RouterResponderStorage.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

import DestinyBlueprint

public struct RouterResponderStorage<
        StaticResponderStorage: StaticResponderStorageProtocol,
        DynamicResponderStorage: DynamicResponderStorageProtocol
    >: RouterResponderStorageProtocol {
    public var `static`:StaticResponderStorage
    public var dynamic:DynamicResponderStorage
    public var conditional:[DestinyRoutePathType:any ConditionalRouteResponderProtocol]

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

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol
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
    public func respondStatically<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        return try await `static`.respond(router: router, socket: socket, startLine: startLine)
    }

    @inlinable
    public func respondDynamically<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout any RequestProtocol,
    ) async throws -> Bool {
        return try await dynamic.respond(router: router, received: received, loaded: loaded, socket: socket, request: &request)
    }
}
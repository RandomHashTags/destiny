
import DestinyBlueprint

/// Default mutable storage that handles conditional, dynamic and static routes.
public final class RouterResponderStorage<
        StaticResponderStorage: MutableStaticResponderStorageProtocol,
        DynamicResponderStorage: MutableDynamicResponderStorageProtocol
    >: MutableRouterResponderStorageProtocol {
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
extension RouterResponderStorage {
    @inlinable
    public func respond(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable
    ) throws(ResponderError) -> Bool {
        if try respondStatically(router: router, socket: socket, startLine: request.startLine) {
            return true
        }
        if try respondDynamically(router: router, socket: socket, request: &request) {
            return true
        }
        if let responder = conditional[request.startLine] {
            return try responder.respond(router: router, socket: socket, request: &request)
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

// MARK: Register
extension RouterResponderStorage {
    @inlinable
    public func register(
        path: SIMD64<UInt8>,
        responder: some StaticRouteResponderProtocol
    ) {
        `static`.register(path: path, responder: responder)
    }

    @inlinable
    public func register(
        route: some DynamicRouteProtocol,
        responder: some DynamicRouteResponderProtocol,
        override: Bool
    ) {
        dynamic.register(route: route, responder: responder, override: override)
    }
}
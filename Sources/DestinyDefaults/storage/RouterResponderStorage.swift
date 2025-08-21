
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
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        if try respondStatically(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        }
        if try respondDynamically(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        }
        let requestStartLine:SIMD64<UInt8>
        do throws(SocketError) {
            requestStartLine = try request.startLine()
        } catch {
            throw .socketError(error)
        }
        if let responder = conditional[requestStartLine] {
            return try responder.respond(router: router, socket: socket, request: &request)
        }
        return false
    }

    @inlinable
    public func respondStatically(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        return try `static`.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
    }

    @inlinable
    public func respondDynamically(
        router: some HTTPRouterProtocol,
        socket: Int32,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        return try dynamic.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
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
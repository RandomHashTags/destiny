
import DestinyBlueprint

/// Default immutable storage that handles conditional, dynamic and static routes.
public struct CompiledRouterResponderStorage<
        StaticResponderStorage: StaticResponderStorageProtocol,
        DynamicResponderStorage: DynamicResponderStorageProtocol
    >: RouterResponderStorageProtocol {
    public let `static`:StaticResponderStorage
    public let dynamic:DynamicResponderStorage
    public let conditional:[SIMD64<UInt8>:any ConditionalRouteResponderProtocol]

    @inlinable
    public init(
        static: StaticResponderStorage,
        dynamic: DynamicResponderStorage,
        conditional: [SIMD64<UInt8>:any ConditionalRouteResponderProtocol]
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
        socket: some FileDescriptor,
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
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        return try `static`.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
    }

    @inlinable
    public func respondDynamically(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) -> Bool {
        return try dynamic.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
    }
}
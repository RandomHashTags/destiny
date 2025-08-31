
import DestinyBlueprint

/// Default immutable storage that handles conditional, dynamic and static routes.
public struct CompiledRouterResponderStorage<
        Storage: ResponderStorageProtocol
    >: RouterResponderStorageProtocol {
    public let storage:Storage
    public let conditional:[SIMD64<UInt8>:any ConditionalRouteResponderProtocol]

    @inlinable
    public init(
        storage: Storage,
        conditional: [SIMD64<UInt8>:any ConditionalRouteResponderProtocol]
    ) {
        self.storage = storage
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
        if try storage.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler) {
            return true
        }
        let requestStartLine:SIMD64<UInt8>
        do throws(SocketError) {
            requestStartLine = try request.startLine()
        } catch {
            throw .socketError(error)
        }
        if let responder = conditional[requestStartLine] {
            try responder.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
            return true
        }
        return false
    }
}
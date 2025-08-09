
import DestinyBlueprint

public final class OpaqueDynamicMiddlewareStorage: MutableOpaqueDynamicMiddlewareStorageProtocol, @unchecked Sendable {
    @usableFromInline
    var middleware:[any OpaqueDynamicMiddlewareProtocol]

    public init(_ middleware: [any OpaqueDynamicMiddlewareProtocol]) {
        self.middleware = middleware
    }

    @inlinable
    public func handle(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) {
        for middleware in middleware {
            if try !middleware.handle(request: &request, response: &response) {
                break
            }
        }
    }

    @inlinable
    public func register(_ middleware: some OpaqueDynamicMiddlewareProtocol) {
        self.middleware.append(middleware)
    }
}

import DestinyBlueprint

public struct CompiledOpaqueDynamicMiddlewareStorage<each Middleware: OpaqueDynamicMiddlewareProtocol>: OpaqueDynamicMiddlewareStorageProtocol {
    public let middleware:(repeat each Middleware)

    public init(_ middleware: (repeat each Middleware)) {
        self.middleware = middleware
    }

    @inlinable
    public func handle(
        for request: inout some HTTPRequestProtocol & ~Copyable,
        with response: inout some DynamicResponseProtocol
    ) throws(MiddlewareError) {
        for middleware in repeat each middleware {
            if try !middleware.handle(request: &request, response: &response) {
                return // TODO: report: using 'break' here instead of 'return' crashes compiler
            }
        }
    }
}
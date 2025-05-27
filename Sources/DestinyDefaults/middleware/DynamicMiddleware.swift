
import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicMiddleware
/// Default Dynamic Middleware implementation which handles requests to dynamic routes.
public struct DynamicMiddleware: DynamicMiddlewareProtocol {
    public let handleLogic:@Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    private var logic:String = "{ _, _ in }"

    public init(
        _ handleLogic: @escaping @Sendable (_ request: inout any HTTPRequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
    ) {
        self.handleLogic = handleLogic
    }

    @inlinable
    public mutating func load() {
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        try await handleLogic(&request, &response)
        return true
    }

    public var debugDescription: String {
        "DynamicMiddleware \(logic)"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        var logic = "\(function.trailingClosure?.debugDescription ?? "{ _, _ in }")"
        for argument in function.arguments {
            if let _ = argument.label?.text {
            } else {
                logic = "\(argument.expression)"
            }
        }
        var middleware = DynamicMiddleware { _, _ in }
        middleware.logic = "\(logic)"
        return middleware
    }
}
#endif
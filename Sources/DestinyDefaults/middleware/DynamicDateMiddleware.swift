
import DestinyBlueprint
import Logging

// MARK: DynamicDateMiddleware
/// Adds the `Date` header to responses for dynamic routes.
public final class DynamicDateMiddleware: DynamicMiddlewareProtocol {
    public init() {
    }

    @inlinable
    public func handle(request: inout any HTTPRequestProtocol, response: inout any DynamicResponseProtocol) async throws -> Bool {
        response.setHeader(key: "Date", value: HTTPDateFormat.shared.nowInlineArray.string())
        return true
    }

    public var debugDescription: String {
        "DynamicDateMiddleware()"
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension DynamicDateMiddleware {
    public static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}
#endif
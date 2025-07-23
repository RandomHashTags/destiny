
#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

/// Core Middleware protocol.
public protocol MiddlewareProtocol: Sendable {

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: SwiftSyntax expression that represents this middleware at compile time.
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self
    #endif
}
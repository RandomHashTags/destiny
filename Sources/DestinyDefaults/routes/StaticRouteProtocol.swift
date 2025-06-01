
import DestinyBlueprint

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

/// Core Static Route protocol where a complete HTTP Message is computed at compile time.
public protocol StaticRouteProtocol: RouteProtocol {
    var startLine: String { get }

    mutating func insertPath<C: Collection<String>>(contentsOf newElements: C, at i: Int)

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// The HTTP Message of this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where it was called.
    ///   - function: SwiftSyntax expression that represents this route.
    ///   - middleware: Static middleware that this route will apply.
    /// - Returns: An `HTTPResponseMessage`.
    /// - Warning: You should apply any statuses and headers using the middleware.
    func response(
        context: MacroExpansionContext?,
        function: FunctionCallExprSyntax?,
        middleware: [any StaticMiddlewareProtocol]
    ) -> any HTTPMessageProtocol

    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where it was called.
    ///   - function: SwiftSyntax expression that represents this route.
    ///   - middleware: Static middleware that this route will apply.
    /// - Throws: any error.
    func responder(
        context: MacroExpansionContext?,
        function: FunctionCallExprSyntax?,
        middleware: [any StaticMiddlewareProtocol]
    ) throws -> (any StaticRouteResponderProtocol)?

    /// Parsing logic for this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `HTTPRouterProtocol` this middleware is assigned to.
    ///   - function: SwiftSyntax expression that represents this route.
    static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Self?
    #endif
}
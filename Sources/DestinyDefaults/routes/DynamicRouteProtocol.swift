
import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

/// Core Dynamic Route protocol where a complete HTTP Message, computed at compile time, is modified upon requests.
public protocol DynamicRouteProtocol: RouteProtocol {
    associatedtype ConcreteDynamicResponse:DynamicResponseProtocol

    /// Default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status: HTTPResponseStatus.Code { get set }

    /// Default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType: HTTPMediaType? { get set }

    /// Path of this route.
    var path: [PathComponent] { get set }

    /// Default HTTP Message computed by default values and static middleware.
    var defaultResponse: ConcreteDynamicResponse { get set }

    /// - Returns: The responder for this route.
    @inlinable func responder() -> any DynamicRouteResponderProtocol

    /// String representation of an initialized route responder conforming to `DynamicRouteResponderProtocol`.
    var responderDebugDescription: String { get }

    /// Applies static middleware to this route.
    /// 
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware<T: StaticMiddlewareProtocol>(_ middleware: [T])

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this dynamic route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context.
    ///   - version: The `HTTPVersion` associated with the `HTTPRouterProtocol`.
    ///   - middleware: The static middleware the associated `HTTPRouterProtocol` uses.
    ///   - function: SwiftSyntax expression that represents this route at compile time.
    /// - Warning: You should apply any statuses and headers using the middleware.
    static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        middleware: [any StaticMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> Self?
    #endif
}

extension DynamicRouteProtocol {
    @inlinable
    public var startLine: String {
        return method.rawNameString() + " /" + path.map({ $0.slug }).joined(separator: "/") + " " + version.string
    }
}
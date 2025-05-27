
import SwiftCompression
import SwiftSyntax
import SwiftSyntaxMacros

/// Core Redirection Route protocol that redirects certain endpoints to other endpoints.
public protocol RedirectionRouteProtocol: RouteProtocol {
    /// The endpoint that has been moved.
    var from: [String] { get }

    /// The redirection endpoint.
    var to: [String] { get }

    /// Status of this redirection route.
    var status: HTTPResponseStatus.Code { get }

    /// The HTTP Message of this route. Computed at compile time.
    /// 
    /// - Throws: any error; if thrown: a compile diagnostic shown describing the issue.
    /// - Returns: a string representing a complete HTTP Message.
    func response() throws -> String

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `HTTPRouterProtocol` this middleware is assigned to.
    ///   - function: SwiftSyntax expression that represents this route.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self?
    #endif
}

// MARK: SwiftCompression
// Redirects do not use compression.
extension RedirectionRouteProtocol {
    public var supportedCompressionAlgorithms: Set<CompressionAlgorithm> {
        get { [] }
        set {}
    }
}
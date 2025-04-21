//
//  StaticRouteProtocol.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

/// Core Static Route protocol where a complete HTTP Message is computed at compile time.
public protocol StaticRouteProtocol : RouteProtocol {
    /// Default status of this route.
    var status : HTTPResponseStatus.Code { get }

    /// Default content type of this route.
    var contentType : HTTPMediaType { get }

    /// Path of this route.
    var path : [String] { get set }
    
    /// Content returned from this route.
    var result : RouteResult { get }

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// The HTTP Message of this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where it was called.
    ///   - function: SwiftSyntax expression that represents this route.
    ///   - middleware: Static middleware that this route will apply.
    /// - Returns: An `HTTPMessage`.
    /// - Warning: You should apply any statuses and headers using the middleware.
    func response(
        context: MacroExpansionContext?,
        function: FunctionCallExprSyntax?,
        middleware: [any StaticMiddlewareProtocol]
    ) -> HTTPMessage

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
    ///   - version: The `HTTPVersion` of the `RouterProtocol` this middleware is assigned to.
    ///   - function: SwiftSyntax expression that represents this route.
    static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        _ function: FunctionCallExprSyntax
    ) -> Self?
    #endif
}

extension StaticRouteProtocol {
    @inlinable
    public var startLine : String {
        return method.rawName.string() + " /" + path.joined(separator: "/") + " " + version.string
    }
}
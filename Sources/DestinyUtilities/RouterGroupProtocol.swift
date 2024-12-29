//
//  RouterGroupProtocol.swift
//
//
//  Created by Evan Anderson on 11/22/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// The core Router Group protocol that handles routes grouped by a single endpoint.
public protocol RouterGroupProtocol : CustomDebugStringConvertible, Sendable {

    @inlinable func staticResponder(for startLine: DestinyRoutePathType) -> StaticRouteResponderProtocol?
    
    @inlinable func dynamicResponder(for request: inout RequestProtocol) -> DynamicRouteResponderProtocol?

    /// Parsing logic for this router group.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context.
    ///   - version: The `HTTPVersion` of the router this router group belongs to.
    ///   - staticMiddleware: The static middleware of the router this router group belongs to.
    ///   - dynamicMiddleware: The dynamic middleware of the router this router group belongs to.
    ///   - function: The SwiftSyntax expression that represents this router group at compile time.
    static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        staticMiddleware: [StaticMiddlewareProtocol],
        dynamicMiddleware: [DynamicMiddlewareProtocol],
        _ function: FunctionCallExprSyntax
    ) -> Self
}
//
//  DynamicRouteProtocol.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

/// The core Route protocol that powers Destiny's dynamic routing where a complete HTTP Response, computed at compile time, is modified upon requests.
public protocol DynamicRouteProtocol : RouteProtocol {
    /// The default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status : HTTPResponse.Status { get set }

    /// The default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType : HTTPMediaType { get set }

    /// The path of this route.
    var path : [PathComponent] { get set }

    /// The default HTTP Response computed by default values and static middleware.
    var defaultResponse : DynamicResponseProtocol { get set }

    /// - Returns: The responder for this route.
    @inlinable func responder() -> DynamicRouteResponderProtocol

    /// A string representing an initialized route responder conforming to `DynamicRouteResponderProtocol`.
    var responderDebugDescription : String { get }

    /// Applies static middleware to this route.
    /// 
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware(_ middleware: [StaticMiddlewareProtocol])

    /// Parsing logic for this dynamic route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context.
    ///   - version: The `HTTPVersion` associated with the `RouterProtocol`.
    ///   - middleware: The static middleware the associated `RouterProtocol` uses.
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    /// - Warning: You need to assign `handlerLogic` properly.
    /// - Warning: You should apply any statuses and headers using the middleware.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self?
}

public extension DynamicRouteProtocol {
    var startLine : String {
        return method.rawValue + " /" + path.map({ $0.slug }).joined(separator: "/") + " " + version.string
    }
}
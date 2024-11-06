//
//  DynamicRouteProtocol.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

/// The core Route protocol that powers Destiny's dynamic routing where a complete HTTP Response, computed at compile, is modified upon requests.
public protocol DynamicRouteProtocol : RouteProtocol, CustomDebugStringConvertible {
    /// The default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status : HTTPResponse.Status? { get set }
    /// The default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType : HTTPField.ContentType { get set }
    /// The path of this route.
    var path : [PathComponent] { get }
    /// Where this route accepts parameters in its path.
    var parameterPathIndexes : Set<Int> { get }
    /// The default HTTP Response computed by default values and static middleware.
    var defaultResponse : DynamicResponseProtocol { get set }
    /// Whether or not this dynamic route responds asynchronously or synchronously.
    var isAsync : Bool { get }
    /// A string representation of the synchronous handler logic, required when parsing from the router macro.
    var handlerLogic : String { get }
    /// A string representation of the asynchronous handler logic, required when parsing from the router macro.
    var handlerLogicAsync : String { get }

    /// Returns a string representing an initialized route responder conforming to `DynamicRouteResponseProtocol`. Computed at compile time.
    /// 
    /// Loads the route responder in a `Router`'s dynamic route responses.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - logic: The string representation of the synchronous/asynchronous handler logic this route uses.
    func responder(version: String, logic: String) -> String

    /// Applies static middleware to this route.
    /// 
    /// Specifically used when adding dynamic routes to a `Router` after the server has already started.
    /// 
    /// If `contentType == nil`, it gets set to `notImplemented` before this function is called.
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware(_ middleware: [StaticMiddlewareProtocol])

    /// Parsing logic for this dynamic route. Computed at compile time.
    /// - Warning: You need to assign `handlerLogic` or `handlerLogicAsync` properly.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - middleware: The static middleware the associated `Router` uses.
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    static func parse(context: some MacroExpansionContext, version: String, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self?
}
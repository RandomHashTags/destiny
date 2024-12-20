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
    var status : HTTPResponse.Status? { get set }

    /// The default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType : HTTPMediaType { get set }

    /// The path of this route.
    var path : [PathComponent] { get }

    /// The default HTTP Response computed by default values and static middleware.
    var defaultResponse : DynamicResponseProtocol { get set }
    
    /// Whether or not this dynamic route responds asynchronously or synchronously.
    var isAsync : Bool { get }

    /// Returns a string representing an initialized route responder conforming to `DynamicRouteResponderProtocol`. Computed at compile time.
    /// 
    /// Loads the route responder in a `RouterProtocol`'s dynamic route responses.
    /// - Parameters:
    ///   - logic: The string representation of the synchronous/asynchronous handler logic this route uses.
    func responder(logic: String) -> String

    /// Applies static middleware to this route.
    /// 
    /// Specifically used when adding dynamic routes to a `RouterProtocol` after the server has already started.
    /// 
    /// If `contentType == nil`, it gets set to `notImplemented` before this function is called.
    /// - Parameters:
    ///   - middleware: The static middleware to apply to this route.
    mutating func applyStaticMiddleware(_ middleware: [StaticMiddlewareProtocol])

    /// Parsing logic for this dynamic route. Computed at compile time.
    /// - Warning: You need to assign `handlerLogic` or `handlerLogicAsync` properly.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - version: The `HTTPVersion` associated with the `RouterProtocol`.
    ///   - middleware: The static middleware the associated `RouterProtocol` uses.
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self?
}
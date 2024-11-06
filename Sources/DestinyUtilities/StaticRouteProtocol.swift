//
//  StaticRouteProtocol.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

/// The core Route protocol that powers Destiny's static routing where a complete HTTP Response is computed at compile time.
public protocol StaticRouteProtocol : RouteProtocol {
    var returnType : RouteReturnType { get }
    /// The default status of this route. May be modified by static middleware at compile time or by dynamic middleware upon requests.
    var status : HTTPResponse.Status? { get }
    /// The default content type of this route. May be modified by static middleware at compile time or dynamic middleware upon requests.
    var contentType : HTTPField.ContentType { get }
    /// The path of this route.
    var path : [String] { get }

    var result : RouteResult { get }

    /// The HTTP Response of this route. Computed at compile time.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - middleware: The static middleware the associated `Router` uses.
    /// - Throws: any error; if thrown: a compile error is thrown describing the issue.
    /// - Returns: a string representing a complete HTTP Response.
    func response(version: String, middleware: [StaticMiddlewareProtocol]) throws -> String

    /// The `StaticRouteResponseProtocol` responder for this route.
    /// 
    /// Specifically used when registering this route after the server has already started.
    /// - Parameters:
    ///   - version: The HTTP version associated with the `Router`.
    ///   - middleware: The static middleware the associated `Router` uses.
    /// - Throws: any error.
    func responder(version: String, middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponseProtocol?

    /// Parsing logic for this static route. Computed at compile time.
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this route at compile time.
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self?
}
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
    /// The return type of this router, which the `result` gets encoded to.
    var returnType : RouteReturnType { get }
    /// The default status of this route.
    var status : HTTPResponse.Status? { get }
    /// The default content type of this route.
    var contentType : HTTPMediaType { get }
    /// The path of this route.
    var path : [String] { get }
    /// The content you want to return from this route.
    var result : RouteResult { get }

    /// The HTTP Response of this route. Computed at compile time.
    /// - Warning: You should apply any statuses and headers using the middleware.
    /// - Parameters:
    ///   - middleware: The static middleware the associated `RouterProtocol` uses.
    /// - Throws: any error; if thrown: a compile error is thrown describing the issue.
    /// - Returns: a string representing a complete HTTP Response.
    func response(middleware: [StaticMiddlewareProtocol]) throws -> String

    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// Specifically used when registering this route after the server has already started.
    /// - Parameters:
    ///   - middleware: The static middleware the associated `RouterProtocol` uses.
    /// - Throws: any error.
    func responder(middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol?

    /// Parsing logic for this route. Computed at compile time.
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `RouterProtocol` this middleware is assigned to.
    ///   - function: The SwiftSyntax expression that represents this route.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self?
}
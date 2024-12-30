//
//  StaticRouteProtocol.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

/// The core Static Route protocol where a complete HTTP Response is computed at compile time.
public protocol StaticRouteProtocol : RouteProtocol {
    /// The return type of this router, which the `result` gets encoded to.
    var returnType : RouteReturnType { get }

    /// The default status of this route.
    var status : HTTPResponse.Status { get }

    /// The default content type of this route.
    var contentType : HTTPMediaType { get }

    /// The path of this route.
    var path : [String] { get set }
    
    /// The content returned from this route.
    var result : RouteResult { get }

    /// The HTTP Response of this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware that this route will apply.
    /// - Returns: An `HTTPMessage`.
    /// - Warning: You should apply any statuses and headers using the middleware.
    func response(middleware: [StaticMiddlewareProtocol]) -> HTTPMessage

    /// The `StaticRouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - middleware: Static middleware that this route will apply.
    /// - Throws: any error.
    func responder(middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol?

    /// Parsing logic for this route.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `RouterProtocol` this middleware is assigned to.
    ///   - function: The SwiftSyntax expression that represents this route.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self?
}

public extension StaticRouteProtocol {
    var startLine : String {
        return method.rawValue + " /" + path.joined(separator: "/") + " " + version.string()
    }
}
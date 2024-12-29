//
//  RedirectionRouteProtocol.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import HTTPTypes
import SwiftCompression
import SwiftSyntax
import SwiftSyntaxMacros

/// The core Redirection Route protocol that redirects certain endpoints to other endpoints.
public protocol RedirectionRouteProtocol : RouteProtocol {
    /// The endpoint that has been moved.
    var from : [String] { get }

    /// The redirection endpoint.
    var to : [String] { get }

    /// The status of this redirection route.
    var status : HTTPResponse.Status { get }

    /// The HTTP Response of this route. Computed at compile time.
    /// 
    /// - Throws: any error; if thrown: a compile error is thrown describing the issue.
    /// - Returns: a string representing a complete HTTP Response.
    func response() throws -> String

    /// Parsing logic for this route. Computed at compile time.
    /// 
    /// - Parameters:
    ///   - context: The macro expansion context where this route is being parsed from.
    ///   - version: The `HTTPVersion` of the `RouterProtocol` this middleware is assigned to.
    ///   - function: The SwiftSyntax expression that represents this route.
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self?
}

// Redirects do not use compression.
public extension RedirectionRouteProtocol {
    var supportedCompressionAlgorithms : Set<CompressionAlgorithm> {
        get { [] }
        set {}
    }
}
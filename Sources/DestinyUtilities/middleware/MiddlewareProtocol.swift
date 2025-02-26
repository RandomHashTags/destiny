//
//  MiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Core Middleware protocol.
public protocol MiddlewareProtocol : Sendable, CustomDebugStringConvertible {

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: SwiftSyntax expression that represents this middleware at compile time.
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self
    #endif
}
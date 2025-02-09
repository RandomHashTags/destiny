//
//  MiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

/// Core Middleware protocol.
public protocol MiddlewareProtocol : Sendable, CustomDebugStringConvertible {

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this middleware at compile time.
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self
    #endif
}
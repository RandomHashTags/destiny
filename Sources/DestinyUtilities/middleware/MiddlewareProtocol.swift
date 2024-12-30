//
//  MiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// The core Middleware protocol.
public protocol MiddlewareProtocol : Sendable, CustomDebugStringConvertible {
    /// Parsing logic for this middleware.
    /// 
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this middleware at compile time.
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self
}
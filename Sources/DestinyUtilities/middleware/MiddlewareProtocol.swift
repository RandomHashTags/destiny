//
//  MiddlewareProtocol.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import SwiftSyntax

/// The core Middleware protocol that powers Destiny's Middleware.
public protocol MiddlewareProtocol : Sendable, CustomDebugStringConvertible {
    /// Parsing logic for this middleware. Computed at compile time.
    /// - Parameters:
    ///   - function: The SwiftSyntax expression that represents this middleware at compile time.
    static func parse(_ function: FunctionCallExprSyntax) -> Self
}
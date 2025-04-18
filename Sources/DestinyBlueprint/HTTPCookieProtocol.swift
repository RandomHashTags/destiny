//
//  HTTPCookieProtocol.swift
//
//
//  Created by Evan Anderson on 2/25/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

public protocol HTTPCookieProtocol : CustomDebugStringConvertible, CustomStringConvertible, Sendable {
    associatedtype CookieName = String
    associatedtype CookieValue = String

    associatedtype Expires

    var name : CookieName { get set }
    var value : CookieValue { get set }

    var maxAge : UInt64 { get set }

    var expires : Expires? { get set }

    var domain : String? { get set }
    var path : String? { get set }

    var isSecure : Bool { get set }
    var isHTTPOnly : Bool { get set }

    #if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
    /// Parsing logic for this cookie.
    /// 
    /// - Parameters:
    ///   - expr: SwiftSyntax expression that represents this cookie at compile time.
    static func parse(context: some MacroExpansionContext, expr: ExprSyntaxProtocol) -> Self?
    #endif
}
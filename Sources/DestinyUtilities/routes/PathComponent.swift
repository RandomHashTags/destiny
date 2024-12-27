//
//  PathComponent.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

import SwiftSyntax

/// Represents an individual path value for a route. Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
public enum PathComponent : CustomDebugStringConvertible, CustomStringConvertible, ExpressibleByStringLiteral, Sendable {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    case literal(String)
    case parameter(String)

    public init(expression: ExprSyntax) {
        self = .init(stringLiteral: expression.stringLiteral?.string ?? expression.functionCall!.calledExpression.memberAccess!.declName.baseName.text)
    }
    public init(stringLiteral value: String) {
        if value.first == ":" {
            self = .parameter(value[value.index(after: value.startIndex)...].replacingOccurrences(of: ":", with: ""))
        } else {
            self = .literal(value.replacingOccurrences(of: ":", with: ""))
        }
    }

    public var debugDescription : String {
        switch self {
            case .literal(let s): return ".literal(\"\(s)\")"
            case .parameter(let s): return ".parameter(\"\(s)\")"
        }
    }
    public var description : String { "\"" + slug + "\"" }

    /// Whether or not this component is a parameter.
    public var isParameter : Bool {
        switch self {
        case .literal(_):   return false
        case .parameter(_): return true
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter. Used to determine where parameters are located in a route's path at compile time.
    public var slug : String {
        switch self {
        case .literal(let value):   return value
        case .parameter(let value): return ":" + value
        }
    }

    /// String representation of this component where the delimiter is omitted (only the name of the path is present).
    public var value : String {
        switch self {
        case .literal(let value):   return value
        case .parameter(let value): return value
        }
    }
}
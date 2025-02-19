//
//  PathComponent.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Represents an individual path value for a route. Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
public enum PathComponent : CustomDebugStringConvertible, CustomStringConvertible, ExpressibleByStringLiteral, Sendable {
    case literal(String)
    case parameter(String)

    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

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

    @inlinable
    public var description : String {
        "\"" + slug + "\""
    }

    /// Whether or not this component is a parameter.
    @inlinable
    public var isParameter : Bool {
        switch self {
        case .literal:   return false
        case .parameter: return true
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter. Used to determine where parameters are located in a route's path at compile time.
    @inlinable
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

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension PathComponent {
    public static func parseArray(context: some MacroExpansionContext, _ expr: ExprSyntax) -> [String] {
        var array:[String] = []
        if let literal:[Substring] = expr.stringLiteral?.string.split(separator: "/") {
            for substring in literal {
                if substring.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expr)
                    return []
                }
                array.append(String(substring))
            }
        } else if let arrayElements:ArrayElementListSyntax = expr.array?.elements {
            for element in arrayElements {
                guard let string:String = element.expression.stringLiteral?.string else { return [] }
                if string.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: element.expression)
                    return []
                }
                array.append(string)
            }
        }
        return array
    }
    public static func parseArray(context: some MacroExpansionContext, _ expr: ExprSyntax) -> [PathComponent] {
        return expr.array?.elements.compactMap({ PathComponent(context: context, expression: $0.expression) }) ?? []
    }

    public init?(context: some MacroExpansionContext, expression: ExprSyntax) {
        guard let string:String = expression.stringLiteral?.string ?? expression.functionCall?.calledExpression.memberAccess?.declName.baseName.text else { return nil }
        if string.contains(" ") {
            Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expression)
            return nil
        }
        self = .init(stringLiteral: string)
    }
}
#endif
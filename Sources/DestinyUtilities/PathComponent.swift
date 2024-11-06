//
//  PathComponent.swift
//
//
//  Created by Evan Anderson on 11/5/24.
//

import SwiftSyntax

public enum PathComponent : Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    case literal(String)
    case parameter(String)

    public init(stringLiteral value: String) {
        if value.first == ":" {
            self = .parameter(String(value[value.index(after: value.startIndex)...]))
        } else {
            self = .literal(value)
        }
    }

    public var description : String { "\"" + slug + "\"" }

    public var isParameter : Bool {
        switch self {
            case .literal(_):   return false
            case .parameter(_): return true
        }
    }

    public var slug : String {
        switch self {
            case .literal(let value):   return value
            case .parameter(let value): return ":" + value
        }
    }

    public var value : String {
        switch self {
            case .literal(let value):   return value
            case .parameter(let value): return value
        }
    }
}

public extension PathComponent {
    static func parse(_ expression: ExprSyntax) -> Self {
        if var string:String = expression.stringLiteral?.string {
            let is_parameter:Bool = string[string.startIndex] == ":"
            string.replace(":", with: "")
            return is_parameter ? .parameter(string) : .literal(string)
        } else {
            let function:FunctionCallExprSyntax = expression.functionCall!
            let target:String = function.calledExpression.memberAccess!.declName.baseName.text
            let value:String = function.arguments.first!.expression.stringLiteral!.string.replacing(":", with: "")
            switch target {
                case "literal": return .literal(value)
                case "parameter": return .parameter(value)
                default: return .literal(value)
            }
        }
    }
}
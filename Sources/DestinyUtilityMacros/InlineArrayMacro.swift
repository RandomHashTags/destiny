//
//  HTTPFieldContentType.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum InlineArrayMacro : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var string:String = "["
        if let s = node.arguments.first?.expression.stringLiteral?.string {
            string.append(s.compactMap {
                guard let v = $0.asciiValue else { return nil }
                return "\(v)"
            }.joined(separator: ","))
        }
        string += "]"
        return "\(raw: string)"
    }
}

#endif
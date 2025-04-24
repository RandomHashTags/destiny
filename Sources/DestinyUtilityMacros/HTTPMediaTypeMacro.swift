//
//  HTTPMediaTypeMacro.swift
//
//
//  Created by Evan Anderson on 4/21/25.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPMediaTypeMacro: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var type = "??????"
        var subType = "??????"
        for argument in node.arguments {
            switch argument.label?.text {
            case "type":
                type = argument.expression.stringLiteral!.string
            case "subType":
                subType = argument.expression.stringLiteral!.string
            default:
                break
            }
        }
        let mimeType = "\(type)/\(subType)".compactMap { $0.asciiValue }
        let string = "HTTPMediaType.Storage<\(mimeType.count)>(type: \"\(type)\", subType: \"\(subType)\", mimeType: \(mimeType))"
        return "\(raw: string)"
    }
}

#endif
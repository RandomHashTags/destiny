//
//  HTTPResponseStatusMacro.swift
//
//
//  Created by Evan Anderson on 4/21/25.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPResponseStatusMacro : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        //var name = "??????"
        var code = 0
        var phrase = "??????"
        for argument in node.arguments {
            switch argument.label?.text {
            //case "name":
                //name = argument.expression.stringLiteral!.string
            case "code":
                code = Int(argument.expression.as(IntegerLiteralExprSyntax.self)!.literal.text)!
            case "phrase":
                phrase = argument.expression.stringLiteral!.string
            default:
                break
            }
        }
        let string = get(code: code, phrase: phrase)
        return "\(raw: string)"
    }

    static func get(code: Int, phrase: String) -> String {
        let phraseCount = phrase.count
        let codePhraseValues = "\(code) \(phrase)".compactMap { $0.asciiValue }
        let phrase = phrase.compactMap { $0.asciiValue }.description
        return "HTTPResponseStatus.Storage<\(phraseCount), \(codePhraseValues.count)>(code: \(code), phrase: \(phrase), codePhrase: \(codePhraseValues))"
    }
}

#endif
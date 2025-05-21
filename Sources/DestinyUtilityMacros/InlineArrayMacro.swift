
#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

enum InlineArrayMacro: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var expectedCount:Int? = nil
        var values:[UInt8] = []
        for argument in node.arguments {
            switch argument.label?.text {
            case "count":
                if let s = argument.expression.as(IntegerLiteralExprSyntax.self)?.literal.text, let i = Int(s) {
                    expectedCount = i
                }
            default:
                let expr = argument.expression
                if let s = expr.stringLiteral?.string ?? expr.as(IntegerLiteralExprSyntax.self)?.literal.text {
                    values.append(contentsOf: s.compactMap { $0.asciiValue })
                }
                break
            }
        }
        if let expectedCount, values.count < expectedCount {
            while values.count < expectedCount {
                values.append(0)
            }
        }
        return "\(raw: "\(values)")"
    }
}

#endif

import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension ResponseBody {
    private static func parseString(_ expr: some ExprSyntaxProtocol) -> String {
        if let s = expr.stringLiteral?.string {
            return s
        } else {
            return expr.description
        }
    }
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> (any ResponseBodyProtocol)? {
        guard let function = expr.functionCall else {
            if let string = expr.stringLiteral?.string {
                return string
            }
            return nil
        }
        guard let firstArg = function.arguments.first else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        switch key {
        case "bytes":
            return IntermediateResponseBody(type: .bytes, firstArg.expression.description)
        case "error":
            return nil // TODO: fix
        case "inlinebytes":
            return IntermediateResponseBody(type: .inlineBytes, firstArg.expression.description)
        case "json":
            return nil // TODO: fix
        case "macroexpansion":
            return IntermediateResponseBody(type: .macroExpansion, firstArg.expression.description)
        case "macroexpansionwithdateheader":
            return IntermediateResponseBody(type: .macroExpansionWithDateHeader, firstArg.expression.description)
        case "staticstring":
            return IntermediateResponseBody(type: .staticString, parseString(firstArg.expression))
        case "staticstringwithdateheader":
            return IntermediateResponseBody(type: .staticStringWithDateHeader, parseString(firstArg.expression))
        case "streamwithdateheader":
            return IntermediateResponseBody(type: .streamWithDateHeader, firstArg.expression.description)
        case "string":
            return parseString(firstArg.expression)
        case "stringwithdateheader":
            return IntermediateResponseBody(type: .stringWithDateHeader, parseString(firstArg.expression))
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: expr))
            return nil
        }
    }
}
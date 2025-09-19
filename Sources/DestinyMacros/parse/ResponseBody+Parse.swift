
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
    ) -> IntermediateResponseBody? {
        guard let function = expr.functionCall else {
            if let string = expr.stringLiteral?.string {
                return .init(type: .string, string)
            }
            return nil
        }
        guard let firstArg = function.arguments.first else { return nil }
        var key = function.calledExpression.memberAccess?.declName.baseName.text.lowercased()
        if key == nil {
            key = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text.lowercased()
        }
        if let key, let type = IntermediateResponseBodyType(rawValue: key) {
            return IntermediateResponseBody(type: type, firstArg.expression.stringLiteral?.string ?? firstArg.expression.description)
        }
        context.diagnose(DiagnosticMsg.unhandled(node: expr))
        return nil
    }
}
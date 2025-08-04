
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPMediaType {
    public static func parse(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> Self? {
        if let s = expr.memberAccess?.declName.baseName.text {
            return parse(memberName: s) ?? parse(fileExtension: s)
        } else if let function = expr.functionCall {
            if let type = function.arguments.first?.expression.stringLiteralString(context: context) {
                if let subType = function.arguments.last?.expression.stringLiteralString(context: context) {
                    return HTTPMediaType(type: type, subType: subType)
                }
            }
        } else {
            context.diagnose(DiagnosticMsg.expectedFunctionCallOrMemberAccessExpr(expr: expr))
        }
        return nil
    }
}
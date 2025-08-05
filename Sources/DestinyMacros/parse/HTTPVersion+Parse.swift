
import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPVersion {
    public static func parse(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> HTTPVersion? {
        guard let text = expr.memberAccess?.declName.baseName.text else {
            context.diagnose(DiagnosticMsg.expectedMemberAccessExpr(expr: expr))
            return nil
        }
        switch text {
        case "v0_9": return .v0_9
        case "v1_0": return .v1_0
        case "v1_1": return .v1_1
        case "v1_2": return .v1_2
        case "v2_0": return .v2_0
        case "v3_0": return .v3_0
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: expr, notes: "text=\(text)"))
            return nil
        }
    }
}
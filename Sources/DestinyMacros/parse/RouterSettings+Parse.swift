
import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

extension RouterSettings {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self {
        var settings = Self()
        guard let function = expr.functionCall else { return settings }
        for arg in function.arguments {
            switch arg.label?.text {
            case "copyable":
                settings.isCopyable = arg.expression.booleanIsTrue
            case "mutable":
                settings.isMutable = arg.expression.booleanIsTrue
            case "name":
                if let n = arg.expression.stringLiteralString(context: context) {
                    settings.name = n
                }
            case "visibility":
                settings.visibility = .init(rawValue: arg.expression.memberAccess?.declName.baseName.text ?? "internal") ?? .internal
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
            }
        }
        return settings
    }
}
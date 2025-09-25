
#if RouterSettings

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
            case "mutable":
                settings.isMutable = arg.expression.booleanIsTrue
            case "dynamicResponsesAreGeneric":
                settings.dynamicResponsesAreGeneric = arg.expression.booleanIsTrue
            case "respondersAreComputedProperties":
                settings.respondersAreComputedProperties = arg.expression.booleanIsTrue
            case "protocolConformances":
                settings.hasProtocolConformances = arg.expression.booleanIsTrue
            case "name":
                if let s = arg.expression.stringLiteralString(context: context) {
                    settings.name = s
                }
            case "requestType":
                if let s = arg.expression.stringLiteralString(context: context) {
                    settings.requestType = s
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

#endif

import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

extension PerfectHashSettings {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self {
        let defaultSettings = Self()
        guard let function = expr.functionCall else { return defaultSettings }
        var enabled = true
        var maxBytes = defaultSettings.maxBytes
        var requireExactPaths = defaultSettings.requireExactPaths
        var relaxedRoutePaths = defaultSettings.relaxedRoutePaths
        for arg in function.arguments {
            switch arg.label?.text {
            case "enabled":
                enabled = arg.expression.booleanIsTrue
            case "maxBytes":
                guard let elements = arg.expression.arrayElements(context: context) else { break }
                maxBytes = elements.compactMap({
                    guard let i = $0.expression.integerLiteral?.literal.text else { return nil }
                    return Int(i)
                })
            case "requireExactPaths":
                requireExactPaths = arg.expression.booleanIsTrue
            case "relaxedRoutePaths":
                guard let elements = arg.expression.arrayElements(context: context) else { break }
                relaxedRoutePaths = Set(elements.compactMap({ $0.expression.stringLiteralString(context: context) }))
            default:
                context.diagnose(DiagnosticMsg.unhandled(node: arg))
                break
            }
        }
        return .init(
            enabled: enabled,
            maxBytes: maxBytes,
            requireExactPaths: requireExactPaths,
            relaxedRoutePaths: relaxedRoutePaths
        )
    }
}
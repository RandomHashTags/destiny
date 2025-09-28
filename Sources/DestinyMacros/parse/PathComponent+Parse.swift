
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension PathComponent {
    public static func parseArray(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> [String] {
        var array = [String]()
        if let literal = expr.stringLiteral?.string.split(separator: "/") {
            for substring in literal {
                if substring.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expr)
                    return []
                }
                array.append(String(substring))
            }
        } else if let arrayElements = expr.array?.elements {
            for element in arrayElements {
                guard let string = element.expression.stringLiteralString(context: context) else { return [] }
                if string.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: element.expression)
                    return []
                }
                array.append(string)
            }
        }
        return array
    }

    public static func parseArray(context: some MacroExpansionContext, _ expr: some ExprSyntaxProtocol) -> [PathComponent] {
        return expr.arrayElements(context: context)?.compactMap({ PathComponent(context: context, expression: $0.expression) }) ?? []
    }

    public init?(context: some MacroExpansionContext, expression: some ExprSyntaxProtocol) {
        guard let string = expression.stringLiteral?.string ?? expression.functionCall?.calledExpression.memberAccess?.declName.baseName.text else { return nil }
        if string.contains(" ") {
            Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expression)
            return nil
        }
        #if NonEmbedded
        self = .init(stringLiteral: string)
        #else
        context.diagnose(DiagnosticMsg.unhandled(node: expression))
        return nil
        #endif
    }
}
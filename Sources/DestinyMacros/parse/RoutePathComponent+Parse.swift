
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension RoutePathComponent {
    public static func parseArray(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> [Self] {
        var array = [RoutePathComponent]()
        if let literal = expr.stringLiteral?.string.split(separator: "/") {
            for substring in literal {
                if substring.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expr)
                    return []
                }
                array.append(.init(stringLiteral: String(substring)))
            }
        } else if let arrayElements = expr.array?.elements {
            for element in arrayElements {
                guard let string = element.expression.stringLiteralString(context: context) else { return [] }
                if string.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: element.expression)
                    return []
                }
                array.append(.init(stringLiteral: string))
            }
        }
        return array
    }
}
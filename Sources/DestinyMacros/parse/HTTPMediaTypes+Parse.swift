
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPMediaType {
    public static func parse(context: some MacroExpansionContext, expr: ExprSyntax) -> Self? {
        if let s = expr.memberAccess?.declName.baseName.text {
            return parse(memberName: s) ?? parse(fileExtension: s)
        } else if let function = expr.functionCall {
            if let type = function.arguments.first?.expression.stringLiteral?.string {
                if let subType = function.arguments.last?.expression.stringLiteral?.string {
                    return HTTPMediaType(type: type, subType: subType)
                }
            }
        }
        return nil
    }
}

import DestinyBlueprint
import SwiftSyntax

extension HTTPResponseStatus {
    public static func parseCode(expr: ExprSyntax) -> Code? {
        guard let member = expr.memberAccess,
            member.declName.baseName.text == "code",
            let base = member.base?.memberAccess,
            base.base?.as(DeclReferenceExprSyntax.self)?.baseName.text == "HTTPResponseStatus"
        else {
            return nil
        }
        return parseCode(staticName: base.declName.baseName.text)
    }
}
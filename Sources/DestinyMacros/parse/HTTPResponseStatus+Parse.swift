
import DestinyBlueprint
import DestinyDefaults
import HTTPResponseStatusExtras
import SwiftSyntax

extension HTTPResponseStatus {
    public static func parseCode(expr: some ExprSyntaxProtocol) -> Code? {
        guard let member = expr.memberAccess,
            member.declName.baseName.text == "code",
            let base = member.base?.memberAccess
        else {
            return nil
        }
        return parseCode(staticName: base.declName.baseName.text)
    }

    public static func parseCode(staticName: String) -> Code? {
        if let v = HTTPStandardResponseStatus(rawValue: staticName) {
            return v.code
        }
        if let v = HTTPNonStandardResponseStatus(rawValue: staticName) {
            return v.code
        }
        return nil
    }
}
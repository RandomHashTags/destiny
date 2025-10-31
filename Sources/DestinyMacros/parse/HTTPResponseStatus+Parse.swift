
import Destiny
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPResponseStatus {
    public static func parseCode(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> Code? {
        guard let member = expr.memberAccess,
            member.declName.baseName.text == "code",
            let base = member.base?.memberAccess
        else {
            if let t = expr.integerLiteral?.literal.text {
                return Code(t)
            }
            context.diagnose(DiagnosticMsg.unhandled(node: expr))
            return nil
        }
        return parseCode(rawValue: base.declName.baseName.text)
    }

    public static func parseCode(rawValue: String) -> Code? {
        #if HTTPStandardResponseStatusRawValues
        if let v = HTTPStandardResponseStatus(rawValue: rawValue) {
            return v.code
        }
        #endif
        #if HTTPNonStandardResponseStatusRawValues
        if let v = HTTPNonStandardResponseStatus(rawValue: rawValue) {
            return v.code
        }
        #endif
        return nil
    }
}
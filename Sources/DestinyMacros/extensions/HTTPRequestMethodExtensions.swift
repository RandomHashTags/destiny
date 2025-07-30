
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPRequestMethod {
    static func parse(expr: some ExprSyntaxProtocol) -> (any HTTPRequestMethodProtocol)? {
        var string:String
        if let v = expr.as(MemberAccessExprSyntax.self)?.declName.baseName.text {
            string = v.lowercased()
        } else if let v = expr.as(StringLiteralExprSyntax.self) {
            string = v.string.lowercased()
        } else {
            return nil
        }
        if string.first == "`" {
            string.removeFirst()
            string.removeLast()
        }
        if let m = HTTPStandardRequestMethod(rawValue: string) {
            return m
        }
        if let m = HTTPNonStandardRequestMethod(rawValue: string) {
            return m
        }
        return nil
    }
}
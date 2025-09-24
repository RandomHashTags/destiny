
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPRequestMethod {
    static func parse(expr: some ExprSyntaxProtocol) -> HTTPRequestMethod? {
        var string:String
        if let v = expr.memberAccess?.declName.baseName.text {
            string = v.lowercased()
        } else if let v = expr.stringLiteral {
            string = v.string.lowercased()
        } else {
            return nil
        }
        if string.first == "`" {
            string.removeFirst()
            string.removeLast()
        }
        #if HTTPStandardRequestMethodRawValues
        if let m = HTTPStandardRequestMethod(rawValue: string) {
            return .init(m)
        }
        #endif
        #if HTTPNonStandardRequestMethodRawValues
        if let m = HTTPNonStandardRequestMethod(rawValue: string) {
            return .init(m)
        }
        #endif
        return nil
    }
}
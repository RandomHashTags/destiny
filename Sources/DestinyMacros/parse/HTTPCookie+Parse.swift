
#if HTTPCookie

import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPCookie {
    /// Parsing logic for this cookie.
    /// 
    /// - Parameters:
    ///   - expr: SwiftSyntax expression that represents this cookie at compile time.
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self? {
        var name:String? = nil
        var value:String? = nil
        var initializer = Initializer.value
        var maxAge:UInt64 = 0
        var expires:String? = nil
        var domain:String? = nil
        var path:String? = nil
        var isSecure = false
        var isHTTPOnly = false
        var isPartitioned = false
        var sameSite:HTTPCookieFlag.SameSite? = nil
        if let function = expr.functionCall {
            for arg in function.arguments {
                switch arg.label?.text {
                case "name":
                    name = arg.expression.stringLiteralString(context: context)
                case "encoding", "value", "uncheckedValue":
                    initializer = .init(rawValue: arg.label!.text)!
                    value = arg.expression.stringLiteralString(context: context)
                case "maxAge":
                    if let s = arg.expression.integerLiteral?.literal.text, let i = UInt64(s) {
                        maxAge = i
                    }
                case "expires":
                    expires = arg.expression.stringLiteralString(context: context)
                case "domain":
                    domain = arg.expression.stringLiteralString(context: context)
                case "path":
                    path = arg.expression.stringLiteralString(context: context)
                case "isSecure":
                    isSecure = arg.expression.booleanIsTrue
                case "isHTTPOnly":
                    isHTTPOnly = arg.expression.booleanIsTrue
                case "isPartitioned":
                    isPartitioned = arg.expression.booleanIsTrue
                case "sameSite":
                    sameSite = HTTPCookieFlag.SameSite(rawValue: arg.expression.memberAccess?.declName.baseName.text ?? "")
                default:
                    context.diagnose(DiagnosticMsg.unhandled(node: arg))
                }
            }
        }
        guard let name, let value else { return nil }
        do throws(HTTPCookieError) {
            switch initializer {

            #if PercentEncoding
            case .encoding:
                return try Self(
                    name: name,
                    encoding: value,
                    maxAge: maxAge,
                    expires: expires,
                    domain: domain,
                    path: path,
                    isSecure: isSecure,
                    isPartitioned: isPartitioned,
                    isHTTPOnly: isHTTPOnly,
                    sameSite: sameSite
                )
            #endif

            case .uncheckedValue:
                return Self(
                    name: name,
                    uncheckedValue: value,
                    maxAge: maxAge,
                    expires: expires,
                    domain: domain,
                    path: path,
                    isSecure: isSecure,
                    isPartitioned: isPartitioned,
                    isHTTPOnly: isHTTPOnly,
                    sameSite: sameSite
                )
            default:
                return try Self(
                    name: name,
                    value: value,
                    maxAge: maxAge,
                    expires: expires,
                    domain: domain,
                    path: path,
                    isSecure: isSecure,
                    isPartitioned: isPartitioned,
                    isHTTPOnly: isHTTPOnly,
                    sameSite: sameSite
                )
            }
        } catch {
            context.diagnose(DiagnosticMsg.httpCookieError(node: expr, error: error))
            return nil
        }
    }

    enum Initializer: String {
        case encoding
        case value
        case uncheckedValue
    }
}

#endif
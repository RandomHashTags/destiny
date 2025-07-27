
#if canImport(FoundationEssentials)
import struct FoundationEssentials.Date
#elseif canImport(Foundation)
import struct Foundation.Date
#endif

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
        expr: ExprSyntaxProtocol
    ) -> Self? {
        var name:CookieName? = nil
        var value:CookieValue? = nil
        var maxAge:UInt64 = 0

        #if canImport(FoundationEssentials) || canImport(Foundation)
        var expires:Date? = nil
        #else
        var expires:String? = nil
        #endif
        var domain:String? = nil
        var path:String? = nil
        var isSecure = false
        var isHTTPOnly = false
        var sameSite:HTTPCookieFlag.SameSite? = nil
        if let function = expr.functionCall {
            for argument in function.arguments {
                switch argument.label?.text {
                case "name":
                    name = argument.expression.stringLiteral?.string
                case "value":
                    value = argument.expression.stringLiteral?.string
                case "maxAge":
                    if let s = argument.expression.integerLiteral?.literal.text, let i = UInt64(s) {
                        maxAge = i
                    }
                case "expires":
                    #if canImport(FoundationEssentials) || canImport(Foundation)
                    expires = nil // TODO: fix
                    #else
                    expires = argument.expression.stringLiteral?.string
                    #endif
                case "domain":
                    domain = argument.expression.stringLiteral?.string
                case "path":
                    path = argument.expression.stringLiteral?.string
                case "isSecure":
                    isSecure = argument.expression.booleanIsTrue
                case "isHTTPOnly":
                    isHTTPOnly = argument.expression.booleanIsTrue
                case "sameSite":
                    sameSite = HTTPCookieFlag.SameSite(rawValue: argument.expression.memberAccess?.declName.baseName.text ?? "")
                default:
                    break
                }
            }
        }
        guard let name, let value else { return nil }
        return Self(
            name: name,
            value: value,
            maxAge: maxAge,
            expires: expires,
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }
}
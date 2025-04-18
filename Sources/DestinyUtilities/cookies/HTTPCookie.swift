//
//  HTTPCookie.swift
//
//
//  Created by Evan Anderson on 2/25/25.
//

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Date
#elseif canImport(Foundation)
import struct Foundation.Date
#endif

import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

public struct HTTPCookie : HTTPCookieProtocol {
    public var name:CookieName
    public var value:CookieValue

    public var maxAge:UInt64 = 0
    var flags:Flag.RawValue = 0

    #if canImport(FoundationEssentials) || canImport(Foundation)
    public var expires:Date?
    #else
    public var expires:String? // TODO: fix?
    #endif

    public var domain:String?
    public var path:String?
    public var sameSite:HTTPCookieFlag.SameSite?

    #if canImport(FoundationEssentials) || canImport(Foundation)
    public init(
        name: CookieName,
        value: CookieValue,
        maxAge: UInt64 = 0,
        expires: Date? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) {
        self.name = name
        self.value = value
        self.maxAge = maxAge
        self.expires = expires
        self.domain = domain
        self.path = path
        self.sameSite = sameSite
        flags = (isSecure || sameSite == HTTPCookieFlag.SameSite.none ? Flag.secure.rawValue : 0) | (isHTTPOnly ? Flag.httpOnly.rawValue : 0)
    }
    #else
    public init(
        name: CookieName,
        value: CookieValue,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) {
        self.name = name
        self.value = value
        self.maxAge = maxAge
        self.expires = expires
        self.domain = domain
        self.path = path
        self.sameSite = sameSite
        flags = (isSecure || sameSite == HTTPCookieFlag.SameSite.none ? Flag.secure.rawValue : 0) | (isHTTPOnly ? Flag.httpOnly.rawValue : 0)
    }
    #endif
}

// MARK: CustomDebugStringConvertible
extension HTTPCookie {
    public var debugDescription : String {
        var string:String = "HTTPCookie("
        string += "name: \"\(name)\", value: \"\(value)\""
        if maxAge > 0 {
            string += ", maxAge: \(maxAge)"
        }
        if let expires {
            string += ", expires: "
            #if canImport(FoundationEssentials) || canImport(Foundation)
            string += expires.debugDescription
            #else
            string += "\"\(expires)\""
            #endif
        }
        if let domain {
            string += ", domain: \"\(domain)\""
        }
        if let path {
            string += ", path: \"\(path)\""
        }
        if let sameSite {
            string += ", sameSite: .\(sameSite)"
        }
        string += ")"
        return string
    }
}

// MARK: CustomStringConvertible
extension HTTPCookie {
    @inlinable
    public var description : String {
        var string:String = "\(name)=\(value)"
        if maxAge > 0 {
            string += "; Max-Age=\(maxAge)"
        }
        if let expires {
            string += "; Expires="
            #if canImport(FoundationEssentials) || canImport(Foundation)
            string += HTTPDateFormat.get(date: expires).string()
            #else
            string += expires
            #endif
        }
        if isSecure {
            string += "; Secure"
        }
        if isHTTPOnly {
            string += "; HttpOnly"
        }
        if let domain {
            string += "; Domain=\(domain)"
        }
        if let path {
            string += "; Path=\(path)"
        }
        if let sameSite {
            string += "; SameSite=\(sameSite.httpValue)"
        }
        return string
    }
}

// MARK: Flags
extension HTTPCookie {
    @usableFromInline
    enum Flag : UInt8 {
        case secure   = 1
        case httpOnly = 2
    }

    @usableFromInline func isFlag(_ flag: Flag) -> Bool { flags & flag.rawValue != 0 }

    @usableFromInline
    mutating func setFlag(_ flag: Flag, _ value: Bool) {
        if value {
            flags |= flag.rawValue
        } else {
            flags &= ~flag.rawValue
        }
    }

    @inlinable
    public var isSecure : Bool {
        get { isFlag(.secure) }
        set { setFlag(.secure, newValue) }
    }

    @inlinable
    public var isHTTPOnly : Bool {
        get { isFlag(.httpOnly) }
        set { setFlag(.httpOnly, newValue) }
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension HTTPCookie {
    public static func parse(context: some MacroExpansionContext, expr: ExprSyntaxProtocol) -> Self? {
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
        var isSecure:Bool = false
        var isHTTPOnly:Bool = false
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
#endif
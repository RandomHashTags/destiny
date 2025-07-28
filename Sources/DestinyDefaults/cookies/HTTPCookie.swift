
import DestinyBlueprint

public struct HTTPCookie: HTTPCookieProtocol, CustomDebugStringConvertible {
    public var name:CookieName
    public var value:CookieValue

    public var maxAge:UInt64 = 0
    package var flags:Flag.RawValue = 0

    public var expiresString:String?

    public var domain:String?
    public var path:String?
    public var sameSite:HTTPCookieFlag.SameSite?

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
        self.expiresString = expires
        self.domain = domain
        self.path = path
        self.sameSite = sameSite
        flags = (isSecure || sameSite == HTTPCookieFlag.SameSite.none ? Flag.secure.rawValue : 0) | (isHTTPOnly ? Flag.httpOnly.rawValue : 0)
    }
}

// MARK: CustomDebugStringConvertible
extension HTTPCookie {
    public var debugDescription: String {
        var string:String = "HTTPCookie("
        string += "name: \"\(name)\", value: \"\(value)\""
        if maxAge > 0 {
            string += ", maxAge: \(maxAge)"
        }
        if let expiresString {
            string += ", expires: \"\(expiresString)\""
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
    public var description: String {
        var string = "\(name)=\(value)"
        if maxAge > 0 {
            string += "; Max-Age=\(maxAge)"
        }
        if let expiresString {
            string += "; Expires=\(expiresString)"
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
    package enum Flag: UInt8 {
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
    public var isSecure: Bool {
        get { isFlag(.secure) }
        set { setFlag(.secure, newValue) }
    }

    @inlinable
    public var isHTTPOnly: Bool {
        get { isFlag(.httpOnly) }
        set { setFlag(.httpOnly, newValue) }
    }
}
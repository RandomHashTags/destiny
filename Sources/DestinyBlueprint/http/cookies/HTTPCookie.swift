
/// Default HTTP Cookie storage.
public struct HTTPCookie: HTTPCookieProtocol {
    @usableFromInline
    package var _name:String

    @usableFromInline
    package var _value:String

    public var maxAge:UInt64 = 0

    @usableFromInline
    var flags:Flag.RawValue = 0

    public var expiresString:String?

    public var domain:String?
    public var path:String?
    public var sameSite:HTTPCookieFlag.SameSite?

    #if Inlinable
    @inlinable
    #endif
    public func name() -> String {
        _name
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setName(_ name: String) {
        _name = name
    }

    #if Inlinable
    @inlinable
    #endif
    public func value() -> String {
        _value
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setValue(_ value: String) throws(HTTPCookieError) {
        try Self.validateValue(value)
        _value = value
    }
}

// MARK: Init
extension HTTPCookie {
    #if Inlinable
    @inlinable
    #endif
    public init(copying cookie: some HTTPCookieProtocol) throws(HTTPCookieError) {
        try self.init(
            name: cookie.name(),
            value: cookie.value(),
            maxAge: cookie.maxAge,
            expires: cookie.expiresString,
            domain: cookie.domain,
            path: cookie.path,
            isSecure: cookie.isSecure,
            isHTTPOnly: cookie.isHTTPOnly,
            sameSite: cookie.sameSite
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public init(unchecked cookie: some HTTPCookieProtocol) {
        self.init(
            name: cookie.name(),
            uncheckedValue: cookie.value(),
            maxAge: cookie.maxAge,
            expires: cookie.expiresString,
            domain: cookie.domain,
            path: cookie.path,
            isSecure: cookie.isSecure,
            isHTTPOnly: cookie.isHTTPOnly,
            sameSite: cookie.sameSite
        )
    }

    #if PercentEncoding

    #if Inlinable
    @inlinable
    #endif
    public init(
        name: String,
        encoding: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) throws(HTTPCookieError) {
        try self.init(
            name: name,
            value: encoding.httpCookiePercentEncoded(),
            maxAge: maxAge,
            expires: expires,
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }

    #endif

    #if Inlinable
    @inlinable
    #endif
    public init(
        name: String,
        value: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) throws(HTTPCookieError) {
        try Self.validateValue(value)
        self.init(
            name: name,
            uncheckedValue: value,
            maxAge: maxAge,
            expires: expires,
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public init(
        name: String,
        uncheckedValue: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false,
        sameSite: HTTPCookieFlag.SameSite? = nil
    ) {
        self._name = name
        self._value = uncheckedValue
        self.maxAge = maxAge
        self.expiresString = expires
        self.domain = domain
        self.path = path
        self.sameSite = sameSite
        flags = (isSecure || sameSite == HTTPCookieFlag.SameSite.none ? Flag.secure.rawValue : 0) | (isHTTPOnly ? Flag.httpOnly.rawValue : 0)
    }
}

// MARK: Validate
extension HTTPCookie {
    /// Validates the provided string is a valid HTTP Cookie Value.
    /// 
    /// - Throws: `HTTPCookieError` if it contains an illegal character.
    #if Inlinable
    @inlinable
    #endif
    public static func validateValue(_ value: String) throws(HTTPCookieError) {
        guard let illegalChar = value.first(where: {
            guard let ascii = $0.asciiValue else { return true }
            return ascii <= 31
                || ascii == 127
                || $0.isWhitespace
                || $0 == ","
                || $0 == ";"
                || $0 == "\""
                || $0 == "\\"
        }) else { return }
        throw .illegalCharacter(illegalChar)
    }
}

// MARK: CustomStringConvertible
extension HTTPCookie {
    #if Inlinable
    @inlinable
    #endif
    public var description: String {
        var string = "\(_name)=\(_value)"
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
    enum Flag: UInt8 {
        case secure   = 1
        case httpOnly = 2
    }

    @inlinable
    @inline(__always)
    func isFlag(_ flag: Flag) -> Bool {
        flags & flag.rawValue != 0
    }

    @inlinable
    @inline(__always)
    mutating func setFlag(_ flag: Flag, _ value: Bool) {
        if value {
            flags |= flag.rawValue
        } else {
            flags &= ~flag.rawValue
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var isSecure: Bool {
        get { isFlag(.secure) }
        set { setFlag(.secure, newValue) }
    }

    #if Inlinable
    @inlinable
    #endif
    public var isHTTPOnly: Bool {
        get { isFlag(.httpOnly) }
        set { setFlag(.httpOnly, newValue) }
    }
}
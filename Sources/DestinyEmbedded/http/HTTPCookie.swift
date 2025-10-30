
#if HTTPCookie

/// Default HTTP Cookie storage.
public struct HTTPCookie: Sendable {
    @usableFromInline
    package var _name:String

    @usableFromInline
    package var _value:String

    /// Maximum age this cookie is valid for.
    public var maxAge:UInt64 = 0

    @usableFromInline
    var flags:Flag.RawValue = 0

    public var expiresString:String?

    public var domain:String?
    public var path:String?
    public var sameSite:HTTPCookieFlag.SameSite?

    /// Name of the cookie.
    public func name() -> String {
        _name
    }

    /// Sets the name of the cookie.
    public mutating func setName(_ name: String) {
        _name = name
    }

    /// Value of the cookie.
    public func value() -> String {
        _value
    }

    /// Sets the value of the cookie.
    /// 
    /// - Throws: `HTTPCookieError` if `value` contains an illegal character.
    public mutating func setValue(_ value: String) throws(HTTPCookieError) {
        try Self.validateValue(value)
        _value = value
    }
}

// MARK: Init
extension HTTPCookie {
    #if PercentEncoding

    /// - Throws: `HTTPCookieError` if `encoding` contains an illegal character.
    public init(
        name: String,
        encoding: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isPartitioned: Bool = false,
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
            isPartitioned: isPartitioned,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }

    #endif

    /// - Throws: `HTTPCookieError` if `value` contains an illegal character.
    public init(
        name: String,
        value: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isPartitioned: Bool = false,
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
            isPartitioned: isPartitioned,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }

    public init(
        name: String,
        uncheckedValue: String,
        maxAge: UInt64 = 0,
        expires: String? = nil,
        domain: String? = nil,
        path: String? = nil,
        isSecure: Bool = false,
        isPartitioned: Bool = false,
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
        flags = (isSecure || sameSite == HTTPCookieFlag.SameSite.none ? Flag.secure.rawValue : 0)
            | (isHTTPOnly ? Flag.httpOnly.rawValue : 0)
            | (isSecure && isPartitioned ? Flag.partitioned.rawValue : 0)
    }
}

// MARK: Validate
extension HTTPCookie {
    /// Validates the provided string is a valid HTTP Cookie Value.
    /// 
    /// - Throws: `HTTPCookieError` if it contains an illegal character.
    public static func validateValue(_ value: String) throws(HTTPCookieError) {
        guard let illegalChar = value.first(where: { !Self.isValidInValue($0) }) else { return }
        throw .illegalCharacter(illegalChar)
    }

    /// Returns: Whether the provided character is allowed in an HTTP Cookie Value.
    public static func isValidInValue(_ char: Character) -> Bool {
        guard let ascii = char.asciiValue else { return false }
        return isValidInValue(ascii)
    }

    /// Returns: Whether the provided byte is allowed in an HTTP Cookie Value.
    public static func isValidInValue(_ byte: UInt8) -> Bool {
        return !(
            byte <= 31
            || byte >= 127
            || byte == .space
            || byte == .comma
            || byte == .semicolon
            || byte == .quotation
            || byte == .backslash
        )
    }
}

// MARK: CustomStringConvertible
extension HTTPCookie: CustomStringConvertible {
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
            if isPartitioned {
                string += "; Partitioned"
            }
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
        case partitioned = 4
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

    /// Whether or not the cookie is secure.
    public var isSecure: Bool {
        get { isFlag(.secure) }
        set { setFlag(.secure, newValue) }
    }

    /// Whether or not the cookie is http only.
    public var isHTTPOnly: Bool {
        get { isFlag(.httpOnly) }
        set { setFlag(.httpOnly, newValue) }
    }

    /// Whether or not the cookie is partitioned.
    /// 
    /// [Read more](https://developer.mozilla.org/en-US/docs/Web/Privacy/Guides/Privacy_sandbox/Partitioned_cookies).
    public var isPartitioned: Bool {
        get { isFlag(.partitioned) }
        set { setFlag(.partitioned, newValue) }
    }
}

#endif
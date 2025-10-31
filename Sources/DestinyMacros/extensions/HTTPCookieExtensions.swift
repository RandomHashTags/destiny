
#if HTTPCookie

import Destiny

// MARK: CustomDebugStringConvertible
extension HTTPCookie: CustomDebugStringConvertible {
    public var debugDescription: String {
        var string = "HTTPCookie(name: \"\(_name)\", uncheckedValue: \"\(_value)\""
        if maxAge > 0 {
            string += ", maxAge: \(maxAge)"
        }
        if let expiresString {
            string += ", expires: \"\(expiresString)\""
        }
        if isSecure {
            string += ", isSecure: true"
            if isPartitioned {
                string += ", isPartitioned: true"
            }
        }
        if isHTTPOnly {
            string += ", isHTTPOnly: true"
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

#endif
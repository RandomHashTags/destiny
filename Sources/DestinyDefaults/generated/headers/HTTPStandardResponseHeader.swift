
#if HTTPStandardResponseHeaders

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields
public enum HTTPStandardResponseHeader {
    case acceptPatch
    case acceptRanges
    case accessControlAllowOrigin
    case accessControlAllowCredentials
    case accessControlAllowHeaders
    case accessControlAllowMethods
    case accessControlExposeHeaders
    case accessControlMaxAge
    case age
    case allow
    case altSvc
    case cacheControl
    case connection
    case contentDisposition
    case contentEncoding
    case contentLanguage
    case contentLength
    case contentLocation
    case contentRange
    case contentType
    case date
    case deltaBase
    case eTag
    case expires
    case im
    case lastModified
    case link
    case location
    case p3p
    case pragma
    case preferenceApplied
    case proxyAuthenticate
    case publicKeyPins
    case retryAfter
    case server
    case setCookie
    case strictTransportSecurity
    case tk
    case trailer
    case transferEncoding
    case upgrade
    case vary
    case via
    case wwwAuthenticate

    /// Lowercased canonical name of the header used for comparison.
    #if Inlinable
    @inlinable
    #endif
    public var canonicalName: String {
        switch self {
        case .acceptPatch: "accept-patch"
        case .acceptRanges: "accept-ranges"
        case .accessControlAllowOrigin: "access-control-allow-origin"
        case .accessControlAllowCredentials: "access-control-allow-credentials"
        case .accessControlAllowHeaders: "access-control-allow-headers"
        case .accessControlAllowMethods: "access-control-allow-methods"
        case .accessControlExposeHeaders: "access-control-expose-headers"
        case .accessControlMaxAge: "access-control-max-age"
        case .age: "age"
        case .allow: "allow"
        case .altSvc: "alt-svc"
        case .cacheControl: "cache-control"
        case .connection: "connection"
        case .contentDisposition: "content-disposition"
        case .contentEncoding: "content-encoding"
        case .contentLanguage: "content-language"
        case .contentLength: "content-length"
        case .contentLocation: "content-location"
        case .contentRange: "content-range"
        case .contentType: "content-type"
        case .date: "date"
        case .deltaBase: "delta-base"
        case .eTag: "etag"
        case .expires: "expires"
        case .im: "im"
        case .lastModified: "last-modified"
        case .link: "link"
        case .location: "location"
        case .p3p: "p3p"
        case .pragma: "pragma"
        case .preferenceApplied: "preference-applied"
        case .proxyAuthenticate: "proxy-authenticate"
        case .publicKeyPins: "public-key-pins"
        case .retryAfter: "retry-after"
        case .server: "server"
        case .setCookie: "set-cookie"
        case .strictTransportSecurity: "strict-transport-security"
        case .tk: "tk"
        case .trailer: "trailer"
        case .transferEncoding: "transfer-encoding"
        case .upgrade: "upgrade"
        case .vary: "vary"
        case .via: "via"
        case .wwwAuthenticate: "www-authenticate"
        }
    }
}

#if HTTPStandardResponseHeaderRawNames
extension HTTPStandardResponseHeader {
    #if Inlinable
    @inlinable
    #endif
    public var rawName: String {
        switch self {
        case .acceptPatch: "Accept-Patch"
        case .acceptRanges: "Accept-Ranges"
        case .accessControlAllowOrigin: "Access-Control-Allow-Origin"
        case .accessControlAllowCredentials: "Access-Control-Allow-Credentials"
        case .accessControlAllowHeaders: "Access-Control-Allow-Headers"
        case .accessControlAllowMethods: "Access-Control-Allow-Methods"
        case .accessControlExposeHeaders: "Access-Control-Expose-Headers"
        case .accessControlMaxAge: "Access-Control-Max-Age"
        case .age: "Age"
        case .allow: "Allow"
        case .altSvc: "Alt-Svc"
        case .cacheControl: "Cache-Control"
        case .connection: "Connection"
        case .contentDisposition: "Content-Disposition"
        case .contentEncoding: "Content-Encoding"
        case .contentLanguage: "Content-Language"
        case .contentLength: "Content-Length"
        case .contentLocation: "Content-Location"
        case .contentRange: "Content-Range"
        case .contentType: "Content-Type"
        case .date: "Date"
        case .deltaBase: "Delta-Base"
        case .eTag: "ETag"
        case .expires: "Expires"
        case .im: "IM"
        case .lastModified: "Last-Modified"
        case .link: "Link"
        case .location: "Location"
        case .p3p: "P3P"
        case .pragma: "Pragma"
        case .preferenceApplied: "Preference-Applied"
        case .proxyAuthenticate: "Proxy-Authenticate"
        case .publicKeyPins: "Public-Key-Pins"
        case .retryAfter: "Retry-After"
        case .server: "Server"
        case .setCookie: "Set-Cookie"
        case .strictTransportSecurity: "Strict-Transport-Security"
        case .tk: "TK"
        case .trailer: "Trailer"
        case .transferEncoding: "Transfer-Encoding"
        case .upgrade: "Upgrade"
        case .vary: "Vary"
        case .via: "Via"
        case .wwwAuthenticate: "WWW-Authenticate"
        }
    }
}
#endif

#if HTTPStandardResponseHeaderHashable
extension HTTPStandardResponseHeader: Hashable {
}
#endif

#if HTTPStandardResponseHeaderRawValues
extension HTTPStandardResponseHeader: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "acceptPatch": self = .acceptPatch
        case "acceptRanges": self = .acceptRanges
        case "accessControlAllowOrigin": self = .accessControlAllowOrigin
        case "accessControlAllowCredentials": self = .accessControlAllowCredentials
        case "accessControlAllowHeaders": self = .accessControlAllowHeaders
        case "accessControlAllowMethods": self = .accessControlAllowMethods
        case "accessControlExposeHeaders": self = .accessControlExposeHeaders
        case "accessControlMaxAge": self = .accessControlMaxAge
        case "age": self = .age
        case "allow": self = .allow
        case "altSvc": self = .altSvc
        case "cacheControl": self = .cacheControl
        case "connection": self = .connection
        case "contentDisposition": self = .contentDisposition
        case "contentEncoding": self = .contentEncoding
        case "contentLanguage": self = .contentLanguage
        case "contentLength": self = .contentLength
        case "contentLocation": self = .contentLocation
        case "contentRange": self = .contentRange
        case "contentType": self = .contentType
        case "date": self = .date
        case "deltaBase": self = .deltaBase
        case "eTag": self = .eTag
        case "expires": self = .expires
        case "im": self = .im
        case "lastModified": self = .lastModified
        case "link": self = .link
        case "location": self = .location
        case "p3p": self = .p3p
        case "pragma": self = .pragma
        case "preferenceApplied": self = .preferenceApplied
        case "proxyAuthenticate": self = .proxyAuthenticate
        case "publicKeyPins": self = .publicKeyPins
        case "retryAfter": self = .retryAfter
        case "server": self = .server
        case "setCookie": self = .setCookie
        case "strictTransportSecurity": self = .strictTransportSecurity
        case "tk": self = .tk
        case "trailer": self = .trailer
        case "transferEncoding": self = .transferEncoding
        case "upgrade": self = .upgrade
        case "vary": self = .vary
        case "via": self = .via
        case "wwwAuthenticate": self = .wwwAuthenticate
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: RawValue {
        switch self {
        case .acceptPatch: "acceptPatch"
        case .acceptRanges: "acceptRanges"
        case .accessControlAllowOrigin: "accessControlAllowOrigin"
        case .accessControlAllowCredentials: "accessControlAllowCredentials"
        case .accessControlAllowHeaders: "accessControlAllowHeaders"
        case .accessControlAllowMethods: "accessControlAllowMethods"
        case .accessControlExposeHeaders: "accessControlExposeHeaders"
        case .accessControlMaxAge: "accessControlMaxAge"
        case .age: "age"
        case .allow: "allow"
        case .altSvc: "altSvc"
        case .cacheControl: "cacheControl"
        case .connection: "connection"
        case .contentDisposition: "contentDisposition"
        case .contentEncoding: "contentEncoding"
        case .contentLanguage: "contentLanguage"
        case .contentLength: "contentLength"
        case .contentLocation: "contentLocation"
        case .contentRange: "contentRange"
        case .contentType: "contentType"
        case .date: "date"
        case .deltaBase: "deltaBase"
        case .eTag: "eTag"
        case .expires: "expires"
        case .im: "im"
        case .lastModified: "lastModified"
        case .link: "link"
        case .location: "location"
        case .p3p: "p3p"
        case .pragma: "pragma"
        case .preferenceApplied: "preferenceApplied"
        case .proxyAuthenticate: "proxyAuthenticate"
        case .publicKeyPins: "publicKeyPins"
        case .retryAfter: "retryAfter"
        case .server: "server"
        case .setCookie: "setCookie"
        case .strictTransportSecurity: "strictTransportSecurity"
        case .tk: "tk"
        case .trailer: "trailer"
        case .transferEncoding: "transferEncoding"
        case .upgrade: "upgrade"
        case .vary: "vary"
        case .via: "via"
        case .wwwAuthenticate: "wwwAuthenticate"
        }
    }
}
#endif

#endif
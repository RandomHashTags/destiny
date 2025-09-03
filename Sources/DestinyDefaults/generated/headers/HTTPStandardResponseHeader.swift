
/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields
public enum HTTPStandardResponseHeader: String, Hashable {
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


#if HTTPStandardRequestHeaders

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields
public enum HTTPStandardRequestHeader {
    case aim
    case accept
    case acceptCharset
    case acceptDatetime
    case acceptEncoding
    case acceptLanguage
    case accessControlRequestHeaders
    case accessControlRequestMethod
    case authorization
    case cacheControl
    case connection
    case contentEncoding
    case contentLength
    case contentType
    case cookie
    case date
    case expect
    case forwarded
    case from
    case host
    case ifMatch
    case ifModifiedSince
    case ifNoneMatch
    case ifRange
    case ifUnmodifiedSince
    case maxForwards
    case origin
    case pragma
    case prefer
    case proxyAuthorization
    case range
    case referer
    case te
    case trailer
    case transferEncoding
    case upgrade
    case userAgent
    case via

    /// Lowercased canonical name of the header used for comparison.
    public var canonicalName: String {
        switch self {
        case .aim: "a-im"
        case .accept: "accept"
        case .acceptCharset: "accept-charset"
        case .acceptDatetime: "accept-datetime"
        case .acceptEncoding: "accept-encoding"
        case .acceptLanguage: "accept-language"
        case .accessControlRequestHeaders: "access-control-request-headers"
        case .accessControlRequestMethod: "access-control-request-method"
        case .authorization: "authorization"
        case .cacheControl: "cache-control"
        case .connection: "connection"
        case .contentEncoding: "content-encoding"
        case .contentLength: "content-length"
        case .contentType: "content-type"
        case .cookie: "cookie"
        case .date: "date"
        case .expect: "expect"
        case .forwarded: "forwarded"
        case .from: "from"
        case .host: "host"
        case .ifMatch: "if-match"
        case .ifModifiedSince: "if-modified-since"
        case .ifNoneMatch: "if-none-match"
        case .ifRange: "if-range"
        case .ifUnmodifiedSince: "if-unmodified-since"
        case .maxForwards: "max-forwards"
        case .origin: "origin"
        case .pragma: "pragma"
        case .prefer: "prefer"
        case .proxyAuthorization: "proxy-authorization"
        case .range: "range"
        case .referer: "referer"
        case .te: "te"
        case .trailer: "trailer"
        case .transferEncoding: "transfer-encoding"
        case .upgrade: "upgrade"
        case .userAgent: "user-agent"
        case .via: "via"
        }
    }
}

#if HTTPStandardRequestHeaderRawNames
extension HTTPStandardRequestHeader {
    public var rawName: String {
        switch self {
        case .aim: "A-IM"
        case .accept: "Accept"
        case .acceptCharset: "Accept-Charset"
        case .acceptDatetime: "Accept-Datetime"
        case .acceptEncoding: "Accept-Encoding"
        case .acceptLanguage: "Accept-Language"
        case .accessControlRequestHeaders: "Access-Control-Request-Headers"
        case .accessControlRequestMethod: "Access-Control-Request-Method"
        case .authorization: "Authorization"
        case .cacheControl: "Cache-Control"
        case .connection: "Connection"
        case .contentEncoding: "Content-Encoding"
        case .contentLength: "Content-Length"
        case .contentType: "Content-Type"
        case .cookie: "Cookie"
        case .date: "Date"
        case .expect: "Expect"
        case .forwarded: "Forwarded"
        case .from: "From"
        case .host: "Host"
        case .ifMatch: "If-Match"
        case .ifModifiedSince: "If-Modified-Since"
        case .ifNoneMatch: "If-None-Match"
        case .ifRange: "If-Range"
        case .ifUnmodifiedSince: "If-Unmodified-Since"
        case .maxForwards: "Max-Forwards"
        case .origin: "Origin"
        case .pragma: "Pragma"
        case .prefer: "Prefer"
        case .proxyAuthorization: "Proxy-Authorization"
        case .range: "Range"
        case .referer: "Referer"
        case .te: "TE"
        case .trailer: "Trailer"
        case .transferEncoding: "Transfer-Encoding"
        case .upgrade: "Upgrade"
        case .userAgent: "User-Agent"
        case .via: "Via"
        }
    }
}
#endif

#if HTTPStandardRequestHeaderHashable
extension HTTPStandardRequestHeader: Hashable {
}
#endif

#if HTTPStandardRequestHeaderRawValues
extension HTTPStandardRequestHeader: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "aim": self = .aim
        case "accept": self = .accept
        case "acceptCharset": self = .acceptCharset
        case "acceptDatetime": self = .acceptDatetime
        case "acceptEncoding": self = .acceptEncoding
        case "acceptLanguage": self = .acceptLanguage
        case "accessControlRequestHeaders": self = .accessControlRequestHeaders
        case "accessControlRequestMethod": self = .accessControlRequestMethod
        case "authorization": self = .authorization
        case "cacheControl": self = .cacheControl
        case "connection": self = .connection
        case "contentEncoding": self = .contentEncoding
        case "contentLength": self = .contentLength
        case "contentType": self = .contentType
        case "cookie": self = .cookie
        case "date": self = .date
        case "expect": self = .expect
        case "forwarded": self = .forwarded
        case "from": self = .from
        case "host": self = .host
        case "ifMatch": self = .ifMatch
        case "ifModifiedSince": self = .ifModifiedSince
        case "ifNoneMatch": self = .ifNoneMatch
        case "ifRange": self = .ifRange
        case "ifUnmodifiedSince": self = .ifUnmodifiedSince
        case "maxForwards": self = .maxForwards
        case "origin": self = .origin
        case "pragma": self = .pragma
        case "prefer": self = .prefer
        case "proxyAuthorization": self = .proxyAuthorization
        case "range": self = .range
        case "referer": self = .referer
        case "te": self = .te
        case "trailer": self = .trailer
        case "transferEncoding": self = .transferEncoding
        case "upgrade": self = .upgrade
        case "userAgent": self = .userAgent
        case "via": self = .via
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .aim: "aim"
        case .accept: "accept"
        case .acceptCharset: "acceptCharset"
        case .acceptDatetime: "acceptDatetime"
        case .acceptEncoding: "acceptEncoding"
        case .acceptLanguage: "acceptLanguage"
        case .accessControlRequestHeaders: "accessControlRequestHeaders"
        case .accessControlRequestMethod: "accessControlRequestMethod"
        case .authorization: "authorization"
        case .cacheControl: "cacheControl"
        case .connection: "connection"
        case .contentEncoding: "contentEncoding"
        case .contentLength: "contentLength"
        case .contentType: "contentType"
        case .cookie: "cookie"
        case .date: "date"
        case .expect: "expect"
        case .forwarded: "forwarded"
        case .from: "from"
        case .host: "host"
        case .ifMatch: "ifMatch"
        case .ifModifiedSince: "ifModifiedSince"
        case .ifNoneMatch: "ifNoneMatch"
        case .ifRange: "ifRange"
        case .ifUnmodifiedSince: "ifUnmodifiedSince"
        case .maxForwards: "maxForwards"
        case .origin: "origin"
        case .pragma: "pragma"
        case .prefer: "prefer"
        case .proxyAuthorization: "proxyAuthorization"
        case .range: "range"
        case .referer: "referer"
        case .te: "te"
        case .trailer: "trailer"
        case .transferEncoding: "transferEncoding"
        case .upgrade: "upgrade"
        case .userAgent: "userAgent"
        case .via: "via"
        }
    }
}
#endif

#endif
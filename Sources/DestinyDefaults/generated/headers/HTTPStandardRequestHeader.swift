
/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields
public enum HTTPStandardRequestHeader: String, Hashable {
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

    @inlinable
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

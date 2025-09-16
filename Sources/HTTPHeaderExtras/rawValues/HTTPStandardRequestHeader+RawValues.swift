
import DestinyDefaults

extension HTTPStandardRequestHeader: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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
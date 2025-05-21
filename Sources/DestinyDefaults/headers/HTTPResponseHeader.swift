
import DestinyBlueprint

// MARK: HTTPRequestHeader
// Why use this over the apple/swift-http-types?
//  - this one performs about the same and doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPField.Name`'s 8,32,32 (alignment, size, stride)

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields
public enum HTTPResponseHeader: String, Hashable {
    // MARK: Standard
    



    // MARK: A
    //case acceptCH
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

    // MARK: C
    case cacheControl
    case connection
    case contentDisposition
    case contentEncoding
    case contentLanguage
    case contentLength
    case contentLocation
    case contentRange
    case contentType

    // MARK: D
    case date
    case deltaBase

    // MARK: E
    case eTag
    case expires

    // MARK: I
    case im

    // MARK: L
    case lastModified
    case link
    case location

    // MARK: P
    case p3p
    case pragma
    case preferenceApplied
    case proxyAuthenticate
    case publicKeyPins
    
    // MARK: R
    case retryAfter

    // MARK: S
    case server
    case setCookie
    case strictTransportSecurity

    // MARK: T
    case tk
    case trailer
    case transferEncoding
    
    // MARK: U
    case upgrade

    // MARK: V
    case vary
    case via

    // MARK: W
    case wwwAuthenticate




    // MARK: Non-standard




    // MARK: C
    case contentSecurityPolicy

    // MARK: E
    case expectCT

    // MARK: N
    case nel

    // MARK: P
    case permissionsPolicy

    // MARK: R
    case refresh
    case reportTo

    // MARK: S
    case status

    // MARK: T
    case timingAllowOrigin

    // MARK: X
    case xContentSecurityPolicy
    case xContentTypeOptions
    case xCorrelationID
    case xPoweredBy
    case xRedirectBy
    case xRequestID
    case xUACompatible
    case xWebKitCSP
    case xXSSProtection
}

// MARK: Raw Name
extension HTTPResponseHeader {
    @inlinable
    public var rawName: InlineArray<32, UInt8> {
        switch self {
        // standard
        //case .acceptCH: #inlineArray(count: 32, "Accept-CH")
        case .acceptPatch: #inlineArray(count: 32, "Accept-Patch")
        case .acceptRanges: #inlineArray(count: 32, "Accept-Ranges")
        case .accessControlAllowOrigin: #inlineArray(count: 32, "Access-Control-Allow-Origin")
        case .accessControlAllowCredentials: #inlineArray(count: 32, "Access-Control-Allow-Credentials")
        case .accessControlAllowHeaders: #inlineArray(count: 32, "Access-Control-Allow-Headers")
        case .accessControlAllowMethods: #inlineArray(count: 32, "Access-Control-Allow-Methods")
        case .accessControlExposeHeaders: #inlineArray(count: 32, "Access-Control-Expose-Headers")
        case .accessControlMaxAge: #inlineArray(count: 32, "Access-Control-Max-Age")
        case .age: #inlineArray(count: 32, "Age")
        case .allow: #inlineArray(count: 32, "Allow")
        case .altSvc: #inlineArray(count: 32, "Alt-Svc")

        case .cacheControl: #inlineArray(count: 32, "Cache-Control")
        case .connection: #inlineArray(count: 32, "Connection")
        case .contentDisposition: #inlineArray(count: 32, "Content-Disposition")
        case .contentEncoding: #inlineArray(count: 32, "Content-Encoding")
        case .contentLanguage: #inlineArray(count: 32, "Content-Language")
        case .contentLength: #inlineArray(count: 32, "Content-Length")
        case .contentLocation: #inlineArray(count: 32, "Content-Location")
        case .contentRange: #inlineArray(count: 32, "Content-Range")
        case .contentType: #inlineArray(count: 32, "Content-Type")

        case .date: #inlineArray(count: 32, "Date")
        case .deltaBase: #inlineArray(count: 32, "Delta-Base")

        case .eTag: #inlineArray(count: 32, "ETag")
        case .expires: #inlineArray(count: 32, "Expires")

        case .im: #inlineArray(count: 32, "IM")

        case .lastModified: #inlineArray(count: 32, "Last-Modified")
        case .link: #inlineArray(count: 32, "Link")
        case .location: #inlineArray(count: 32, "Location")

        case .p3p: #inlineArray(count: 32, "P3P")
        case .pragma: #inlineArray(count: 32, "Pragma")
        case .preferenceApplied: #inlineArray(count: 32, "Preference-Applied")
        case .proxyAuthenticate: #inlineArray(count: 32, "Proxy-Authenticate")
        case .publicKeyPins: #inlineArray(count: 32, "Public-Key-Pins")

        case .retryAfter: #inlineArray(count: 32, "Retry-After")


        case .server: #inlineArray(count: 32, "Server")
        case .setCookie: #inlineArray(count: 32, "Set-Cookie")
        case .strictTransportSecurity: #inlineArray(count: 32, "Strict-Transport-Security")

        case .tk: #inlineArray(count: 32, "TK")
        case .trailer: #inlineArray(count: 32, "Trailer")
        case .transferEncoding: #inlineArray(count: 32, "Transfer-Encoding")

        case .upgrade: #inlineArray(count: 32, "Upgrade")

        case .vary: #inlineArray(count: 32, "Vary")
        case .via: #inlineArray(count: 32, "Via")

        case .wwwAuthenticate: #inlineArray(count: 32, "WWW-Authenticate")

        // non-standard
        case .contentSecurityPolicy: #inlineArray(count: 32, "Content-Security-Policy")

        case .expectCT: #inlineArray(count: 32, "Expect-CT")

        case .nel: #inlineArray(count: 32, "NEL")
        
        case .permissionsPolicy: #inlineArray(count: 32, "Permissions-Policy")

        case .refresh: #inlineArray(count: 32, "Refresh")
        case .reportTo: #inlineArray(count: 32, "Report-To")

        case .status: #inlineArray(count: 32, "Status")

        case .timingAllowOrigin: #inlineArray(count: 32, "Timing-Allow-Origin")

        case .xContentSecurityPolicy: #inlineArray(count: 32, "X-Content-Security-Policy")
        case .xContentTypeOptions: #inlineArray(count: 32, "X-Content-Type-Options")
        case .xCorrelationID: #inlineArray(count: 32, "X-Correlation-ID")
        case .xPoweredBy: #inlineArray(count: 32, "X-Powered-By")
        case .xRedirectBy: #inlineArray(count: 32, "X-Redirect-By")
        case .xRequestID: #inlineArray(count: 32, "X-Request-ID")
        case .xUACompatible: #inlineArray(count: 32, "X-UA-Compatible")
        case .xWebKitCSP: #inlineArray(count: 32, "X-WebKit-CSP")
        case .xXSSProtection: #inlineArray(count: 32, "X-XSS-Protection")
        }
    }
}

// MARK: Raw Name String
extension HTTPResponseHeader {
    @inlinable
    public var rawNameString: String {
        return rawName.string()
    }
}

// MARK: Static raw name
// Convenience properties; used so we don't pay performance overhead when we don't want to
extension HTTPResponseHeader {
    internal static func get(_ header: Self) -> String { header.rawNameString }

    public static let acceptPatchRawName = get(.acceptPatch)
    public static let accessControlAllowOriginRawName = get(.accessControlAllowOrigin)
    public static let accessControlAllowCredentialsRawName = get(.accessControlAllowCredentials)
    public static let accessControlAllowHeadersRawName = get(.accessControlAllowHeaders)
    public static let accessControlAllowMethodsRawName = get(.accessControlAllowMethods)
    public static let accessControlExposeHeadersRawName = get(.accessControlExposeHeaders)
    public static let accessControlMaxAgeRawName = get(.accessControlMaxAge)
    public static let contentTypeRawName = get(.contentType)
    public static let varyRawName = get(.vary)
}

// MARK: Accept-CH
/*
extension HTTPResponseHeader {
    public enum AcceptCH: String, Sendable {
        case experimental
    }
}*/

// MARK: Accept-Ranges
extension HTTPResponseHeader {
    public enum AcceptRanges: String, Sendable {
        case bytes
    }
}

// MARK: TK
extension HTTPResponseHeader {
    public enum TK: String, Sendable {
        case disregardingDNT
        case dynamic
        case gatewayToMultipleParties
        case notTracking
        case tracking
        case trackingOnlyIfConsented
        case trackingWithConsent
        case underConstruction
        case updated

        public var rawName: String {
            switch self {
            case .disregardingDNT: return "D"
            case .dynamic: return "?"
            case .gatewayToMultipleParties: return "G"
            case .notTracking: return "N"
            case .tracking: return "T"
            case .trackingOnlyIfConsented: return "P"
            case .trackingWithConsent: return "C"
            case .underConstruction: return "!"
            case .updated: return "U"
            }
        }
    }
}
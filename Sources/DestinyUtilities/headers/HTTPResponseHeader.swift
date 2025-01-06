//
//  HTTPRequestHeader.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

// MARK: HTTPRequestHeader
// Why use this over the apple/swift-http-types?
//  - this one performs about the same and doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPField.Name`'s 8,32,32 (alignment, size, stride)

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields
public enum HTTPResponseHeader : String, Hashable {
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

// MARK: Raw name
public extension HTTPResponseHeader {
    @inlinable
    var rawName : String {
        switch self {
        // standard
        //case .acceptCH: return "Accept-CH"
        case .acceptPatch: return "Accept-Patch"
        case .acceptRanges: return "Accept-Ranges"
        case .accessControlAllowOrigin: return "Access-Control-Allow-Origin"
        case .accessControlAllowCredentials: return "Access-Control-Allow-Credentials"
        case .accessControlAllowHeaders: return "Access-Control-Allow-Headers"
        case .accessControlAllowMethods: return "Access-Control-Allow-Methods"
        case .accessControlExposeHeaders: return "Access-Control-Expose-Headers"
        case .accessControlMaxAge: return "Access-Control-Max-Age"
        case .age: return "Age"
        case .allow: return "Allow"
        case .altSvc: return "Alt-Svc"

        case .cacheControl: return "Cache-Control"
        case .connection: return "Connection"
        case .contentDisposition: return "Content-Disposition"
        case .contentEncoding: return "Content-Encoding"
        case .contentLanguage: return "Content-Language"
        case .contentLength: return "Content-Length"
        case .contentLocation: return "Content-Location"
        case .contentRange: return "Content-Range"
        case .contentType: return "Content-Type"

        case .date: return "Date"
        case .deltaBase: return "Delta-Base"

        case .eTag: return "ETag"
        case .expires: return "Expires"

        case .im: return "IM"

        case .lastModified: return "Last-Modified"
        case .link: return "Link"
        case .location: return "Location"

        case .p3p: return "P3P"
        case .pragma: return "Pragma"
        case .preferenceApplied: return "Preference-Applied"
        case .proxyAuthenticate: return "Proxy-Authenticate"
        case .publicKeyPins: return "Public-Key-Pins"

        case .retryAfter: return "Retry-After"


        case .server: return "Server"
        case .setCookie: return "Set-Cookie"
        case .strictTransportSecurity: return "Strict-Transport-Security"

        case .tk: return "TK"
        case .trailer: return "Trailer"
        case .transferEncoding: return "Transfer-Encoding"

        case .upgrade: return "Upgrade"

        case .vary: return "Vary"
        case .via: return "Via"

        case .wwwAuthenticate: return "WWW-Authenticate"

        // non-standard
        case .contentSecurityPolicy: return "Content-Security-Policy"

        case .expectCT: return "Expect-CT"

        case .nel: return "NEL"
        
        case .permissionsPolicy: return "Permissions-Policy"

        case .refresh: return "Refresh"
        case .reportTo: return "Report-To"

        case .status: return "Status"

        case .timingAllowOrigin: return "Timing-Allow-Origin"

        case .xContentSecurityPolicy: return "X-Content-Security-Policy"
        case .xContentTypeOptions: return "X-Content-Type-Options"
        case .xCorrelationID: return "X-Correlation-ID"
        case .xPoweredBy: return "X-Powered-By"
        case .xRedirectBy: return "X-Redirect-By"
        case .xRequestID: return "X-Request-ID"
        case .xUACompatible: return "X-UA-Compatible"
        case .xWebKitCSP: return "X-WebKit-CSP"
        case .xXSSProtection: return "X-XSS-Protection"
        }
    }
}

// MARK: Static raw name
// Convenience properties; used so we don't pay performance overhead when we don't want to
public extension HTTPResponseHeader {
    internal static func get(_ header: Self) -> String { header.rawName }

    static let acceptPatchRawName:String = get(.acceptPatch)
    static let accessControlAllowOriginRawName:String = get(.accessControlAllowOrigin)
    static let accessControlAllowCredentialsRawName:String = get(.accessControlAllowCredentials)
    static let accessControlAllowHeadersRawName:String = get(.accessControlAllowHeaders)
    static let accessControlAllowMethodsRawName:String = get(.accessControlAllowMethods)
    static let accessControlExposeHeadersRawName:String = get(.accessControlExposeHeaders)
    static let accessControlMaxAgeRawName:String = get(.accessControlMaxAge)
    static let varyRawName:String = get(.vary)
}

// MARK: Accept-CH
/*
public extension HTTPResponseHeader {
    enum AcceptCH : String, Sendable {
        case experimental
    }
}*/

// MARK: Accept-Ranges
public extension HTTPResponseHeader {
    enum AcceptRanges : String, Sendable {
        case bytes
    }
}

// MARK: TK
public extension HTTPResponseHeader {
    enum TK : String, Sendable {
        case disregardingDNT
        case dynamic
        case gatewayToMultipleParties
        case notTracking
        case tracking
        case trackingOnlyIfConsented
        case trackingWithConsent
        case underConstruction
        case updated

        public var rawName : String {
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
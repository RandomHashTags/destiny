//
//  HTTPRequestHeader.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

import SwiftCompression
import SwiftSyntax

// MARK: HTTPRequestHeader
// Why use this over the apple/swift-http-types?
//  - this one performs about the same but doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPField.Name`'s 8,32,32 (alignment, size, stride)

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields
public enum HTTPRequestHeader : String {
    // MARK: Standard




    // MARK: A
    case aim
    case accept
    case acceptCharset
    case acceptDatetime
    case acceptEncoding
    case acceptLanguage
    case accessControlRequestMethod
    case accessControlRequestHeaders
    case authorization

    // MARK: C
    case cacheControl
    case connection
    case contentEncoding
    case contentLength
    case contentType
    case cookie

    // MARK: D
    case date

    // MARK: E
    case expect

    // MARK: F
    case forwarded
    case from

    // MARK H
    case host
    
    // MARK: I
    case ifMatch
    case ifModifiedSince
    case ifNoneMatch
    case ifRange
    case ifUnmodifiedSince

    // MARK: M
    case maxForwards

    // MARL: O
    case origin

    // MARK: P
    case pragma
    case prefer
    case proxyAuthorization

    // MARK: R
    case range
    case referer

    // MARK: T
    case te
    case trailer
    case transferEncoding

    // MARK: U
    case upgrade
    case userAgent

    // MARK: V
    case via




    // MARK: Non-standard




    // MARK: C
    case correlationID

    // MARK: D
    case dnt

    // MARK: F
    case frontEndHttps

    // MARK: P
    case proxyConnection

    // MARK: S
    case saveData
    case secGPC
    
    // MARK: U
    case upgradeInsecureRequests

    // MARK: X
    case xATTDeviceID
    case xCorrelationID
    case xCsrfToken
    case xForwardedFor
    case xForwardedHost
    case xForwardedProto
    case xHttpMethodOverride
    case xRequestID
    case xRequestedWith
    case xUIDH
    case xWapProfile
}

// MARK: Raw name
public extension HTTPRequestHeader {
    @inlinable
    var rawName : String {
        switch self {
        // standard
        case .aim: return "A-IM"
        case .accept: return "Accept"
        case .acceptCharset: return "Accept-Charset"
        case .acceptDatetime: return "Accept-Datetime"
        case .acceptEncoding: return "Accept-Encoding"
        case .acceptLanguage: return "Accept-Language"
        case .accessControlRequestHeaders: return "Access-Control-Request-Headers"
        case .accessControlRequestMethod: return "Access-Control-Request-Method"
        case .authorization: return "Authorization"

        case .cacheControl: return "Cache-Control"
        case .connection: return "Connection"
        case .contentEncoding: return "Content-Encoding"
        case .contentLength: return "Content-Length"
        case .contentType: return "Content-Type"
        case .cookie: return "Cookie"

        case .date: return "Date"

        case .expect: return "Expect"

        case .forwarded: return "Forwarded"
        case .from: return "From"

        case .host: return "Host"

        case .ifMatch: return "If-Match"
        case .ifModifiedSince: return "If-Modified-Since"
        case .ifNoneMatch: return "If-None-Match"
        case .ifRange: return "If-Range"
        case .ifUnmodifiedSince: return "If-Unmodified-Since"

        case .maxForwards: return "Max-Forwards"

        case .origin: return "Origin"

        case .pragma: return "Pragma"
        case .prefer: return "Prefer"
        case .proxyAuthorization: return "Proxy-Authorization"

        case .range: return "Range"
        case .referer: return "Referer"

        case .te: return "TE"
        case .trailer: return "Trailer"
        case .transferEncoding: return "Transfer-Encoding"

        case .upgrade: return "Upgrade"
        case .userAgent: return "User-Agent"

        case .via: return "Via"
        
        // non-standard
        case .correlationID: return "Correlation-ID"

        case .dnt: return "DNT"

        case .frontEndHttps: return "Front-End-Https"

        case .proxyConnection: return "Proxy-Connection"

        case .saveData: return "Save-Data"
        case .secGPC: return "Sec-GPC"

        case .upgradeInsecureRequests: return "Upgrade-Insecure-Requests"

        case .xATTDeviceID: return "X-ATT-Device-Id"
        case .xCorrelationID: return "X-Correlation-ID"
        case .xCsrfToken: return "X-Csrf-Token"
        case .xForwardedFor: return "X-Forwarded-For"
        case .xForwardedHost: return "X-Forwarded-Host"
        case .xForwardedProto: return "X-Forwarded-Proto"
        case .xHttpMethodOverride: return "X-Http-Method-Override"
        case .xRequestID: return "X-Request-ID"
        case .xRequestedWith: return "X-Requested-With"
        case .xUIDH: return "X-UIDH"
        case .xWapProfile: return "X-Wap-Profile"
        }
    }
}

// MARK: Static raw name
public extension HTTPRequestHeader {
    internal static func get(_ header: Self) -> String { header.rawName }

    static let originRawName:String = get(.origin)
}

// MARK: Accept-Encoding
public extension HTTPRequestHeader {
    struct AcceptEncoding : Sendable {
        public let compression:CompressionAlgorithm
    }
}

// MARK: Range
public extension HTTPRequestHeader {
    enum Range : Sendable {
        case bytes(from: Int, to: Int)
    }
}

// MARK: X-Requested-With
public extension HTTPRequestHeader {
    enum XRequestedWith : String, Sendable {
        case xmlHttpRequest

        @inlinable
        public var rawName : String {
            switch self {
            case .xmlHttpRequest: return "XMLHttpRequest"
            }
        }
    }
}

// MARK: SwiftSyntax extensions
public extension HTTPRequestHeader {
    init?(expr: ExprSyntaxProtocol) {
        guard let string:String = expr.memberAccess?.declName.baseName.text else { return nil }
        if let value:Self = Self(rawValue: string) {
            self = value
        } else {
            return nil
        }
    }
}
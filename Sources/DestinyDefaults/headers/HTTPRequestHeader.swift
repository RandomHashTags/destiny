
import DestinyBlueprint
import OrderedCollections
import SwiftCompression

// MARK: HTTPRequestHeader
// Why use this over the apple/swift-http-types?
//  - this one performs about the same but doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPField.Name`'s 8,32,32 (alignment, size, stride)

/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields
public enum HTTPRequestHeader: String {
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

// MARK: Raw Name
extension HTTPRequestHeader {
    @inlinable
    public var rawName: InlineArray<32, UInt8> {
        switch self {
        // standard
        case .aim: #inlineArray(count: 32, "A-IM")
        case .accept: #inlineArray(count: 32, "Accept")
        case .acceptCharset: #inlineArray(count: 32, "Accept-Charset")
        case .acceptDatetime: #inlineArray(count: 32, "Accept-Datetime")
        case .acceptEncoding: #inlineArray(count: 32, "Accept-Encoding")
        case .acceptLanguage: #inlineArray(count: 32, "Accept-Language")
        case .accessControlRequestHeaders: #inlineArray(count: 32, "Access-Control-Request-Headers")
        case .accessControlRequestMethod: #inlineArray(count: 32, "Access-Control-Request-Method")
        case .authorization: #inlineArray(count: 32, "Authorization")

        case .cacheControl: #inlineArray(count: 32, "Cache-Control")
        case .connection: #inlineArray(count: 32, "Connection")
        case .contentEncoding: #inlineArray(count: 32, "Content-Encoding")
        case .contentLength: #inlineArray(count: 32, "Content-Length")
        case .contentType: #inlineArray(count: 32, "Content-Type")
        case .cookie: #inlineArray(count: 32, "Cookie")

        case .date: #inlineArray(count: 32, "Date")

        case .expect: #inlineArray(count: 32, "Expect")

        case .forwarded: #inlineArray(count: 32, "Forwarded")
        case .from: #inlineArray(count: 32, "From")

        case .host: #inlineArray(count: 32, "Host")

        case .ifMatch: #inlineArray(count: 32, "If-Match")
        case .ifModifiedSince: #inlineArray(count: 32, "If-Modified-Since")
        case .ifNoneMatch: #inlineArray(count: 32, "If-None-Match")
        case .ifRange: #inlineArray(count: 32, "If-Range")
        case .ifUnmodifiedSince: #inlineArray(count: 32, "If-Unmodified-Since")

        case .maxForwards: #inlineArray(count: 32, "Max-Forwards")

        case .origin: #inlineArray(count: 32, "Origin")

        case .pragma: #inlineArray(count: 32, "Pragma")
        case .prefer: #inlineArray(count: 32, "Prefer")
        case .proxyAuthorization: #inlineArray(count: 32, "Proxy-Authorization")

        case .range: #inlineArray(count: 32, "Range")
        case .referer: #inlineArray(count: 32, "Referer")

        case .te: #inlineArray(count: 32, "TE")
        case .trailer: #inlineArray(count: 32, "Trailer")
        case .transferEncoding: #inlineArray(count: 32, "Transfer-Encoding")

        case .upgrade: #inlineArray(count: 32, "Upgrade")
        case .userAgent: #inlineArray(count: 32, "User-Agent")

        case .via: #inlineArray(count: 32, "Via")
        
        // non-standard
        case .correlationID: #inlineArray(count: 32, "Correlation-ID")

        case .dnt: #inlineArray(count: 32, "DNT")

        case .frontEndHttps: #inlineArray(count: 32, "Front-End-Https")

        case .proxyConnection: #inlineArray(count: 32, "Proxy-Connection")

        case .saveData: #inlineArray(count: 32, "Save-Data")
        case .secGPC: #inlineArray(count: 32, "Sec-GPC")

        case .upgradeInsecureRequests: #inlineArray(count: 32, "Upgrade-Insecure-Requests")

        case .xATTDeviceID: #inlineArray(count: 32, "X-ATT-Device-Id")
        case .xCorrelationID: #inlineArray(count: 32, "X-Correlation-ID")
        case .xCsrfToken: #inlineArray(count: 32, "X-Csrf-Token")
        case .xForwardedFor: #inlineArray(count: 32, "X-Forwarded-For")
        case .xForwardedHost: #inlineArray(count: 32, "X-Forwarded-Host")
        case .xForwardedProto: #inlineArray(count: 32, "X-Forwarded-Proto")
        case .xHttpMethodOverride: #inlineArray(count: 32, "X-Http-Method-Override")
        case .xRequestID: #inlineArray(count: 32, "X-Request-ID")
        case .xRequestedWith: #inlineArray(count: 32, "X-Requested-With")
        case .xUIDH: #inlineArray(count: 32, "X-UIDH")
        case .xWapProfile: #inlineArray(count: 32, "X-Wap-Profile")
        }
    }
}

// MARK: Raw Name String
extension HTTPRequestHeader {
    @inlinable
    public var rawNameString: String {
        return rawName.string()
    }
}

// MARK: Static raw name
extension HTTPRequestHeader {
    @inlinable
    static func get(_ header: Self) -> String { header.rawNameString }

    public static let originRawName:String = get(.origin)
}

// MARK: Accept-Encoding
extension HTTPRequestHeader {
    public struct AcceptEncoding: Sendable {
        public let compression:CompressionAlgorithm
    }
}

// MARK: Range
extension HTTPRequestHeader {
    public enum Range: Sendable {
        case bytes(from: Int, to: Int)
    }
}

// MARK: X-Requested-With
extension HTTPRequestHeader {
    public enum XRequestedWith: String, Sendable {
        case xmlHttpRequest

        @inlinable
        public var rawName: String {
            switch self {
            case .xmlHttpRequest: "XMLHttpRequest"
            }
        }
    }
}

#if canImport(SwiftSyntax)

import SwiftSyntax
// MARK: SwiftSyntax
extension HTTPRequestHeader {
    public init?(expr: ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text else { return nil }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            return nil
        }
    }
}
#endif

#if canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

import SwiftDiagnostics
import SwiftSyntaxMacros

// MARK: SwiftSyntaxMacros
extension HTTPRequestHeader {
    /// - Returns: The valid headers in a dictionary.
    public static func parse(context: some MacroExpansionContext, _ expr: ExprSyntax) -> OrderedDictionary<String, String> {
        guard let dictionary:[(String, String)] = expr.dictionary?.content.as(DictionaryElementListSyntax.self)?.compactMap({
            guard let key = HTTPRequestHeader.parse(context: context, $0.key) else { return nil }
            let value = $0.value.stringLiteral?.string ?? ""
            return (key, value)
        }) else {
            return [:]
        }
        var headers:OrderedDictionary<String, String> = [:]
        headers.reserveCapacity(dictionary.count)
        for (key, value) in dictionary {
            headers[key] = value
        }
        return headers
    }
}
extension HTTPRequestHeader {
    public static func parse(context: some MacroExpansionContext, _ expr: ExprSyntax) -> String? {
        guard let key = expr.stringLiteral?.string else { return nil }
        guard !key.contains(" ") else {
            context.diagnose(Diagnostic(node: expr, message: DiagnosticMsg(id: "spacesNotAllowedInHTTPFieldName", message: "Spaces aren't allowed in HTTP field names.")))
            return nil
        }
        return key
    }
}
#endif
//
//  HTTPResponseStatus.swift
//
//
//  Created by Evan Anderson on 1/20/25.
//

import SwiftSyntax

// MARK: HTTPResponseStatus
/// https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPResponseStatus : String, Hashable, Sendable {





    // MARK: 1xx
    case `continue`
    case switchingProtocols
    @available(*, deprecated, message: "Deprecated")
    case processing
    case earlyHints

    // MARK: 2xx
    case ok
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case imUsed

    // MARK: 3xx
    case multipleChoices
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case temporaryRedirect
    case permanentRedirect

    // MARK: 4xx
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case misdirectedRequest
    case unprocessableContent
    case locked
    case failedDependency
    case tooEarly
    case upgradeRequired
    case preconditionRequired
    case tooManyRequests
    case requestHeaderFieldsTooLarge
    case unavailableForLegalReasons

    // MARK: 5xx
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired

    // MARK: Unofficial
    case thisIsFine
    case pageExpired
    case methodFailure
    case enhanceYourCalm
    case shopifySecurityRejection
    case blockedByWindowsParentalControls
    case invalidToken
    case tokenRequired
    case bandwidthLimitExceeded
    case siteIsOverloaded
    case siteIsFrozen
    case originDNSError
    case temporarityDisabled
    case networkReadTimeoutError
    case networkConnectTimeoutError
    case unexpectedToken
    case nonStandard

    // MARK: Internet Information Services
    case loginTimeout
    case retryWith
    case redirect

    // MARK: nginx
    case noResponse
    case requestHeaderTooLarge
    case sslCertificateError
    case sslCertificateRequired
    case httpRequestSendToHTTPSPort
    case clientClosedRequest

    // MARK: Cloudflare
    case webServerReturnedAnUnknownError
    case webServerIsDown
    case connectionTimedOut
    case originIsUnreachable
    case aTimeoutOccurred
    case sslHandshakeFailed
    case invalidSSLCertificate
    case issueResolvingOriginHostname

    // MARK: AWS Elastic Load Balancing
    case _000
    case _460
    case _463
    case _464
    case _561
}

// MARK: CustomStringConvertible
extension HTTPResponseStatus : CustomStringConvertible {
    @inlinable
    public var description : String {
        "\(code) \(phrase)"
    }
}

// MARK: CustomDebugStringConvertible
extension HTTPResponseStatus : CustomDebugStringConvertible {
    @inlinable
    public var debugDescription : String {
        "HTTPResponseStatus.\(rawValue)"
    }
}

// MARK: Code
extension HTTPResponseStatus {
    @inlinable
    public var code : Int {
        switch self {
        case .continue: return 100
        case .switchingProtocols: return 101
        case .processing: return 102
        case .earlyHints: return 103

        case .ok: return 200
        case .created: return 201
        case .accepted: return 202
        case .nonAuthoritativeInformation: return 203
        case .noContent: return 204
        case .resetContent: return 205
        case .partialContent: return 206
        case .multiStatus: return 207
        case .alreadyReported: return 208
        case .imUsed: return 226

        case .multipleChoices: return 300
        case .movedPermanently: return 301
        case .found: return 302
        case .seeOther: return 303
        case .notModified: return 304
        case .useProxy: return 305
        case .temporaryRedirect: return 307
        case .permanentRedirect: return 308

        case .badRequest: return 400
        case .unauthorized: return 401
        case .paymentRequired: return 402
        case .forbidden: return 403
        case .notFound: return 404
        case .methodNotAllowed: return 405
        case .notAcceptable: return 406
        case .proxyAuthenticationRequired: return 407
        case .requestTimeout: return 408
        case .conflict: return 409
        case .gone: return 410
        case .lengthRequired: return 411
        case .preconditionFailed: return 412
        case .payloadTooLarge: return 413
        case .uriTooLong: return 414
        case .unsupportedMediaType: return 415
        case .rangeNotSatisfiable: return 416
        case .expectationFailed: return 417
        case .imATeapot: return 418
        case .misdirectedRequest: return 421
        case .unprocessableContent: return 422
        case .locked: return 423
        case .failedDependency: return 424
        case .tooEarly: return 425
        case .upgradeRequired: return 426
        case .preconditionRequired: return 428
        case .tooManyRequests: return 429
        case .requestHeaderFieldsTooLarge: return 431
        case .unavailableForLegalReasons: return 451

        case .internalServerError: return 500
        case .notImplemented: return 501
        case .badGateway: return 502
        case .serviceUnavailable: return 503
        case .gatewayTimeout: return 504
        case .httpVersionNotSupported: return 505
        case .variantAlsoNegotiates: return 506
        case .insufficientStorage: return 507
        case .loopDetected: return 508
        case .notExtended: return 510
        case .networkAuthenticationRequired: return 511

        case .thisIsFine: return 218
        case .pageExpired: return 419
        case .methodFailure: return 420
        case .enhanceYourCalm: return 420
        case .shopifySecurityRejection: return 430
        case .blockedByWindowsParentalControls: return 450
        case .invalidToken: return 498
        case .tokenRequired: return 499
        case .bandwidthLimitExceeded: return 509
        case .siteIsOverloaded: return 529
        case .siteIsFrozen: return 530
        case .originDNSError: return 530
        case .temporarityDisabled: return 540
        case .networkReadTimeoutError: return 598
        case .networkConnectTimeoutError: return 599
        case .unexpectedToken: return 783
        case .nonStandard: return 999

        case .loginTimeout: return 440
        case .retryWith: return 449
        case .redirect: return 451

        case .noResponse: return 444
        case .requestHeaderTooLarge: return 494
        case .sslCertificateError: return 495
        case .sslCertificateRequired: return 496
        case .httpRequestSendToHTTPSPort: return 497
        case .clientClosedRequest: return 499

        case .webServerReturnedAnUnknownError: return 520
        case .webServerIsDown: return 521
        case .connectionTimedOut: return 522
        case .originIsUnreachable: return 523
        case .aTimeoutOccurred: return 524
        case .sslHandshakeFailed: return 525
        case .invalidSSLCertificate: return 526
        case .issueResolvingOriginHostname: return 530

        case ._000: return 000
        case ._460: return 460
        case ._463: return 463
        case ._464: return 464
        case ._561: return 561
        }
    }
}

// MARK: Phrase
extension HTTPResponseStatus {
    @inlinable
    public var phrase : String {
        switch self {
        case .continue: return "Continue"
        case .switchingProtocols: return "Switching Protocols"
        case .processing: return "Processing"
        case .earlyHints: return "Early Hints"

        case .ok: return "OK"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .nonAuthoritativeInformation: return "Non-Authoritative Information"
        case .noContent: return "No Content"
        case .resetContent: return "Reset Content"
        case .partialContent: return "Partial Content"
        case .multiStatus: return "Multi-Status"
        case .alreadyReported: return "Already Reported"
        case .imUsed: return "IM Used"

        case .multipleChoices: return "Multiple Choices"
        case .movedPermanently: return "Moved Permanently"
        case .found: return "Found"
        case .seeOther: return "See Other"
        case .notModified: return "Not Modified"
        case .useProxy: return "Use Proxy"
        case .temporaryRedirect: return "Temporary Redirect"
        case .permanentRedirect: return "Permanent Redirect"

        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .paymentRequired: return "Payment Required"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .methodNotAllowed: return "Method Not Allowed"
        case .notAcceptable: return "Not Acceptable"
        case .proxyAuthenticationRequired: return "Proxy Authentication Required"
        case .requestTimeout: return "Request Timeout"
        case .conflict: return "Conflict"
        case .gone: return "Gone"
        case .lengthRequired: return "Length Required"
        case .preconditionFailed: return "Precondition Failed"
        case .payloadTooLarge: return "Payload Too Large"
        case .uriTooLong: return "URI Too Long"
        case .unsupportedMediaType: return "Unsupported Media Type"
        case .rangeNotSatisfiable: return "Range Not Satisfiable"
        case .expectationFailed: return "Expectation Failed"
        case .imATeapot: return "I'm a teapot"
        case .misdirectedRequest: return "Misdirected Request"
        case .unprocessableContent: return "Unprocessable Content"
        case .locked: return "Locked"
        case .failedDependency: return "Failed Dependency"
        case .tooEarly: return "Too Early"
        case .upgradeRequired: return "Upgrade Required"
        case .preconditionRequired: return "Precondition Required"
        case .tooManyRequests: return "Too Many Requests"
        case .requestHeaderFieldsTooLarge: return "Request Header Fields Too Large"
        case .unavailableForLegalReasons: return "Unavailable For Legal Reasons"

        case .internalServerError: return "Internal Server Error"
        case .notImplemented: return "Not Implemented"
        case .badGateway: return "Bad Gateway"
        case .serviceUnavailable: return "Service Unavailable"
        case .gatewayTimeout: return "Gateway Timeout"
        case .httpVersionNotSupported: return "HTTP Version Not Supported"
        case .variantAlsoNegotiates: return "Variant Also Negotiates"
        case .insufficientStorage: return "Insufficient Storage"
        case .loopDetected: return "Loop Detected"
        case .notExtended: return "Not Extended"
        case .networkAuthenticationRequired: return "Network Authentication Required"

        case .thisIsFine: return "This is fine"
        case .pageExpired: return "Page Expired"
        case .methodFailure: return "Method Failure"
        case .enhanceYourCalm: return "Enhance Your Calm"
        case .shopifySecurityRejection: return "Shopify Security Rejection"
        case .blockedByWindowsParentalControls: return "Blocked by Windows Parental Controls"
        case .invalidToken: return "Invalid Token"
        case .tokenRequired: return "Token Required"
        case .bandwidthLimitExceeded: return "Bandwidth Limit Exceeded"
        case .siteIsOverloaded: return "Site is overloaded"
        case .siteIsFrozen: return "Site is frozen"
        case .originDNSError: return "Origin DNS Error"
        case .temporarityDisabled: return "Temporarily Disabled"
        case .networkReadTimeoutError: return "Network read timeout error"
        case .networkConnectTimeoutError: return "Network Connect Timeout Error"
        case .unexpectedToken: return "Unexpected Token"
        case .nonStandard: return "Non-standard"

        case .loginTimeout: return "Login Time-out"
        case .retryWith: return "Retry With"
        case .redirect: return "Redirect"

        case .noResponse: return "No Response"
        case .requestHeaderTooLarge: return "Request header too large"
        case .sslCertificateError: return "SSL Certificate Error"
        case .sslCertificateRequired: return "SSL Certificate Required"
        case .httpRequestSendToHTTPSPort: return "HTTP Request Sent to HTTPS Port"
        case .clientClosedRequest: return "Client Closed Request"

        case .webServerReturnedAnUnknownError: return "Web Server Returned an Unknown Error"
        case .webServerIsDown: return "Web Server Is Down"
        case .connectionTimedOut: return "Connection Timed Out"
        case .originIsUnreachable: return "Origin Is Unreachable"
        case .aTimeoutOccurred: return "A Timeout Occurred"
        case .sslHandshakeFailed: return "SSL Handshake Failed"
        case .invalidSSLCertificate: return "Invalid SSL Certificate"
        case .issueResolvingOriginHostname: return "Issue Resolving Origin Hostname"

        case ._000: return ""
        case ._460: return ""
        case ._463: return ""
        case ._464: return ""
        case ._561: return ""
        }
    }
}

// MARK: Init ExprSyntax
extension HTTPResponseStatus {
    public init?(expr: ExprSyntax) {
        guard let string:String = expr.memberAccess?.declName.baseName.text, let status:Self = Self(rawValue: string) else { return nil }
        self = status
    }
}
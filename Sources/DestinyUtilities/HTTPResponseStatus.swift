//
//  HTTPResponseStatus.swift
//
//
//  Created by Evan Anderson on 1/20/25.
//

import DestinyBlueprint
import SwiftSyntax

// MARK: HTTPResponseStatus
/// HTTP Status Codes. 
/// 
/// Useful links:
/// - Standard Registry: https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
/// - Wikipedia: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPResponseStatus : String, Hashable, Sendable {




    // MARK: 1xx

    /// - Code: 100
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.100
    case `continue`

    /// - Code: 101
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.101
    case switchingProtocols

    /// - Code: 102
    @available(*, deprecated, message: "Deprecated")
    case processing

    /// - Code: 103
    case earlyHints

    // MARK: 2xx
    /// - Code: 200
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.200
    case ok

    /// - Code: 201
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.201
    case created

    /// - Code: 202
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.202
    case accepted

    /// - Code: 203
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.203
    case nonAuthoritativeInformation

    /// - Code: 204
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.204
    case noContent

    /// - Code: 205
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.205
    case resetContent

    /// - Code: 206
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.206
    case partialContent

    /// - Code: 207
    case multiStatus

    /// - Code: 208
    case alreadyReported

    /// - Code: 226
    case imUsed

    // MARK: 3xx
    /// - Code: 300
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.300
    case multipleChoices

    /// - Code: 301
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.301
    case movedPermanently

    /// - Code: 302
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.302
    case found

    /// - Code: 303
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.303
    case seeOther

    /// - Code: 304
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.304
    case notModified

    /// - Code: 305
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.305
    case useProxy

    /// - Code: 307
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.307
    case temporaryRedirect

    /// - Code: 308
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.308
    case permanentRedirect

    // MARK: 4xx
    /// - Code: 400
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.400
    case badRequest

    /// - Code: 401
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.401
    case unauthorized

    /// - Code: 402
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.402
    case paymentRequired

    /// - Code: 403
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.403
    case forbidden

    /// - Code: 404
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.404
    case notFound

    /// - Code: 405
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.405
    case methodNotAllowed

    /// - Code: 406
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.406
    case notAcceptable

    /// - Code: 407
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.407
    case proxyAuthenticationRequired

    /// - Code: 408
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.408
    case requestTimeout

    /// - Code: 409
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.409
    case conflict

    /// - Code: 410
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.410
    case gone

    /// - Code: 411
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.411
    case lengthRequired

    /// - Code: 412
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.412
    case preconditionFailed

    /// - Code: 413
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.413
    case payloadTooLarge

    /// - Code: 414
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.414
    case uriTooLong

    /// - Code: 415
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.415
    case unsupportedMediaType

    /// - Code: 416
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.416
    case rangeNotSatisfiable

    /// - Code: 417
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.410
    case expectationFailed

    /// - Code: 418
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.410
    case imATeapot

    /// - Code: 421
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.421
    case misdirectedRequest

    /// - Code: 422
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.422
    case unprocessableContent
    
    /// - Code: 423
    case locked

    /// - Code: 424
    case failedDependency

    /// - Code: 425
    case tooEarly

    /// - Code: 426
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.426
    case upgradeRequired

    /// - Code: 428
    case preconditionRequired

    /// - Code: 429
    case tooManyRequests

    /// - Code: 431
    case requestHeaderFieldsTooLarge

    /// - Code: 451
    case unavailableForLegalReasons

    // MARK: 5xx
    /// - Code: 500
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.500
    case internalServerError

    /// - Code: 501
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.501
    case notImplemented

    /// - Code: 502
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.502
    case badGateway

    /// - Code: 503
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.503
    case serviceUnavailable

    /// - Code: 504
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.504
    case gatewayTimeout

    /// - Code: 505
    /// 
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.505
    case httpVersionNotSupported

    /// - Code: 506
    case variantAlsoNegotiates

    /// - Code: 507
    case insufficientStorage

    /// - Code: 508
    case loopDetected

    /// - Code: 510
    case notExtended

    /// - Code: 511
    case networkAuthenticationRequired

    // MARK: Unofficial
    /// - Code: 218
    case thisIsFine

    /// - Code: 419
    case pageExpired

    /// - Code: 420
    case methodFailure

    /// - Code: 420
    case enhanceYourCalm

    /// - Code: 430
    case shopifySecurityRejection

    /// - Code: 450
    case blockedByWindowsParentalControls

    /// - Code: 498
    case invalidToken

    /// - Code: 499
    case tokenRequired

    /// - Code: 509
    case bandwidthLimitExceeded

    /// - Code: 529
    case siteIsOverloaded

    /// - Code: 530
    case siteIsFrozen

    /// - Code: 530
    case originDNSError

    /// - Code: 540
    case temporarityDisabled

    /// - Code: 598
    case networkReadTimeoutError

    /// - Code: 599
    case networkConnectTimeoutError

    /// - Code: 783
    case unexpectedToken

    /// - Code: 999
    case nonStandard

    // MARK: Internet Information Services
    /// - Code: 440
    case loginTimeout

    /// - Code: 449
    case retryWith

    /// - Code: 451
    case redirect

    // MARK: nginx
    /// - Code: 444
    case noResponse

    /// - Code: 494
    case requestHeaderTooLarge

    /// - Code: 495
    case sslCertificateError

    /// - Code: 496
    case sslCertificateRequired

    /// - Code: 497
    case httpRequestSendToHTTPSPort

    /// - Code: 499
    case clientClosedRequest

    // MARK: Cloudflare
    /// - Code: 520
    case webServerReturnedAnUnknownError

    /// - Code: 521
    case webServerIsDown

    /// - Code: 522
    case connectionTimedOut

    /// - Code: 523
    case originIsUnreachable

    /// - Code: 524
    case aTimeoutOccurred

    /// - Code: 525
    case sslHandshakeFailed

    /// - Code: 526
    case invalidSSLCertificate

    /// - Code: 530
    case issueResolvingOriginHostname

    // MARK: AWS Elastic Load Balancing
    /// - Code: 000
    case _000

    /// - Code: 460
    case _460

    /// - Code: 463
    case _463

    /// - Code: 464
    case _464

    /// - Code: 561
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
    /// Code for this status.
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
    public var phrase : InlineArray<40, UInt8> {
        switch self {
        case .continue: #inlineArray(count: 40, "Continue")
        case .switchingProtocols: #inlineArray(count: 40, "Switching Protocols")
        case .processing: #inlineArray(count: 40, "Processing")
        case .earlyHints: #inlineArray(count: 40, "Early Hints")

        case .ok: #inlineArray(count: 40, "OK")
        case .created: #inlineArray(count: 40, "Created")
        case .accepted: #inlineArray(count: 40, "Accepted")
        case .nonAuthoritativeInformation: #inlineArray(count: 40, "Non-Authoritative Information")
        case .noContent: #inlineArray(count: 40, "No Content")
        case .resetContent: #inlineArray(count: 40, "Reset Content")
        case .partialContent: #inlineArray(count: 40, "Partial Content")
        case .multiStatus: #inlineArray(count: 40, "Multi-Status")
        case .alreadyReported: #inlineArray(count: 40, "Already Reported")
        case .imUsed: #inlineArray(count: 40, "IM Used")

        case .multipleChoices: #inlineArray(count: 40, "Multiple Choices")
        case .movedPermanently: #inlineArray(count: 40, "Moved Permanently")
        case .found: #inlineArray(count: 40, "Found")
        case .seeOther: #inlineArray(count: 40, "See Other")
        case .notModified: #inlineArray(count: 40, "Not Modified")
        case .useProxy: #inlineArray(count: 40, "Use Proxy")
        case .temporaryRedirect: #inlineArray(count: 40, "Temporary Redirect")
        case .permanentRedirect: #inlineArray(count: 40, "Permanent Redirect")

        case .badRequest: #inlineArray(count: 40, "Bad Request")
        case .unauthorized: #inlineArray(count: 40, "Unauthorized")
        case .paymentRequired: #inlineArray(count: 40, "Payment Required")
        case .forbidden: #inlineArray(count: 40, "Forbidden")
        case .notFound: #inlineArray(count: 40, "Not Found")
        case .methodNotAllowed: #inlineArray(count: 40, "Method Not Allowed")
        case .notAcceptable: #inlineArray(count: 40, "Not Acceptable")
        case .proxyAuthenticationRequired: #inlineArray(count: 40, "Proxy Authentication Required")
        case .requestTimeout: #inlineArray(count: 40, "Request Timeout")
        case .conflict: #inlineArray(count: 40, "Conflict")
        case .gone: #inlineArray(count: 40, "Gone")
        case .lengthRequired: #inlineArray(count: 40, "Length Required")
        case .preconditionFailed: #inlineArray(count: 40, "Precondition Failed")
        case .payloadTooLarge: #inlineArray(count: 40, "Payload Too Large")
        case .uriTooLong: #inlineArray(count: 40, "URI Too Long")
        case .unsupportedMediaType: #inlineArray(count: 40, "Unsupported Media Type")
        case .rangeNotSatisfiable: #inlineArray(count: 40, "Range Not Satisfiable")
        case .expectationFailed: #inlineArray(count: 40, "Expectation Failed")
        case .imATeapot: #inlineArray(count: 40, "I'm a teapot")
        case .misdirectedRequest: #inlineArray(count: 40, "Misdirected Request")
        case .unprocessableContent: #inlineArray(count: 40, "Unprocessable Content")
        case .locked: #inlineArray(count: 40, "Locked")
        case .failedDependency: #inlineArray(count: 40, "Failed Dependency")
        case .tooEarly: #inlineArray(count: 40, "Too Early")
        case .upgradeRequired: #inlineArray(count: 40, "Upgrade Required")
        case .preconditionRequired: #inlineArray(count: 40, "Precondition Required")
        case .tooManyRequests: #inlineArray(count: 40, "Too Many Requests")
        case .requestHeaderFieldsTooLarge: #inlineArray(count: 40, "Request Header Fields Too Large")
        case .unavailableForLegalReasons: #inlineArray(count: 40, "Unavailable For Legal Reasons")

        case .internalServerError: #inlineArray(count: 40, "Internal Server Error")
        case .notImplemented: #inlineArray(count: 40, "Not Implemented")
        case .badGateway: #inlineArray(count: 40, "Bad Gateway")
        case .serviceUnavailable: #inlineArray(count: 40, "Service Unavailable")
        case .gatewayTimeout: #inlineArray(count: 40, "Gateway Timeout")
        case .httpVersionNotSupported: #inlineArray(count: 40, "HTTP Version Not Supported")
        case .variantAlsoNegotiates: #inlineArray(count: 40, "Variant Also Negotiates")
        case .insufficientStorage: #inlineArray(count: 40, "Insufficient Storage")
        case .loopDetected: #inlineArray(count: 40, "Loop Detected")
        case .notExtended: #inlineArray(count: 40, "Not Extended")
        case .networkAuthenticationRequired: #inlineArray(count: 40, "Network Authentication Required")

        case .thisIsFine: #inlineArray(count: 40, "This is fine")
        case .pageExpired: #inlineArray(count: 40, "Page Expired")
        case .methodFailure: #inlineArray(count: 40, "Method Failure")
        case .enhanceYourCalm: #inlineArray(count: 40, "Enhance Your Calm")
        case .shopifySecurityRejection: #inlineArray(count: 40, "Shopify Security Rejection")
        case .blockedByWindowsParentalControls: #inlineArray(count: 40, "Blocked by Windows Parental Controls")
        case .invalidToken: #inlineArray(count: 40, "Invalid Token")
        case .tokenRequired: #inlineArray(count: 40, "Token Required")
        case .bandwidthLimitExceeded: #inlineArray(count: 40, "Bandwidth Limit Exceeded")
        case .siteIsOverloaded: #inlineArray(count: 40, "Site is overloaded")
        case .siteIsFrozen: #inlineArray(count: 40, "Site is frozen")
        case .originDNSError: #inlineArray(count: 40, "Origin DNS Error")
        case .temporarityDisabled: #inlineArray(count: 40, "Temporarily Disabled")
        case .networkReadTimeoutError: #inlineArray(count: 40, "Network read timeout error")
        case .networkConnectTimeoutError: #inlineArray(count: 40, "Network Connect Timeout Error")
        case .unexpectedToken: #inlineArray(count: 40, "Unexpected Token")
        case .nonStandard: #inlineArray(count: 40, "Non-standard")

        case .loginTimeout: #inlineArray(count: 40, "Login Time-out")
        case .retryWith: #inlineArray(count: 40, "Retry With")
        case .redirect: #inlineArray(count: 40, "Redirect")

        case .noResponse: #inlineArray(count: 40, "No Response")
        case .requestHeaderTooLarge: #inlineArray(count: 40, "Request header too large")
        case .sslCertificateError: #inlineArray(count: 40, "SSL Certificate Error")
        case .sslCertificateRequired: #inlineArray(count: 40, "SSL Certificate Required")
        case .httpRequestSendToHTTPSPort: #inlineArray(count: 40, "HTTP Request Sent to HTTPS Port")
        case .clientClosedRequest: #inlineArray(count: 40, "Client Closed Request")

        case .webServerReturnedAnUnknownError: #inlineArray(count: 40, "Web Server Returned an Unknown Error")
        case .webServerIsDown: #inlineArray(count: 40, "Web Server Is Down")
        case .connectionTimedOut: #inlineArray(count: 40, "Connection Timed Out")
        case .originIsUnreachable: #inlineArray(count: 40, "Origin Is Unreachable")
        case .aTimeoutOccurred: #inlineArray(count: 40, "A Timeout Occurred")
        case .sslHandshakeFailed: #inlineArray(count: 40, "SSL Handshake Failed")
        case .invalidSSLCertificate: #inlineArray(count: 40, "Invalid SSL Certificate")
        case .issueResolvingOriginHostname: #inlineArray(count: 40, "Issue Resolving Origin Hostname")

        case ._000: #inlineArray(count: 40, "")
        case ._460: #inlineArray(count: 40, "")
        case ._463: #inlineArray(count: 40, "")
        case ._464: #inlineArray(count: 40, "")
        case ._561: #inlineArray(count: 40, "")
        }
    }
}

// MARK: Phrase string
extension HTTPResponseStatus {
    @inlinable
    public var phraseString : String {
        return phrase.string()
    }
}

// MARK: Category
extension HTTPResponseStatus {
    /// Category of the HTTP Response Status.
    public enum Category {
        /// Status codes that are 1xx; request received, continuing process.
        case informational
        
        /// Status codes that are 2xx; action was successfully received, understood and accepted.
        case successful

        /// Status codes that are 3xx; further action must be taken in order to complete the request.
        case redirection

        /// Status codes that are 4xx; request contains bad syntax or cannot be fulfilled.
        case clientError

        /// Status codes that are 5xx; server failed to fulfill an apparently valid request.
        case serverError

        /// Status codes not officially recognized by the HTTP standard (any status code not 1xx, 2xx, 3xx, 4xx, or 5xx).
        case nonStandard
    }

    /// Category that the status code falls under.
    @inlinable
    public var category : Category {
        switch code {
        case 100...199: .informational
        case 200...299: .successful
        case 300...399: .redirection
        case 400...499: .clientError
        case 500...599: .serverError
        default:        .nonStandard
        }
    }
}

#if canImport(SwiftSyntax)
// MARK: SwiftSyntax
extension HTTPResponseStatus {
    public init?(expr: ExprSyntax) {
        guard let string = expr.memberAccess?.declName.baseName.text, let status = Self(rawValue: string) else { return nil }
        self = status
    }
}
#endif
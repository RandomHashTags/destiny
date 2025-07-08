
// MARK: HTTPResponseStatus
/// HTTP Status Codes. 
/// 
/// Useful links:
/// - Standard Registry: https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
/// - Wikipedia: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPResponseStatus {
    public typealias Code = UInt16
}

// MARK: Storage
extension HTTPResponseStatus {
    public protocol StorageProtocol: Hashable, Sendable {
        associatedtype ConcreteCodePhrase:InlineArrayProtocol

        var code: HTTPResponseStatus.Code { get }
        var codePhrase: ConcreteCodePhrase { get }
        var category: HTTPResponseStatus.Category { get }
    }
    /// Default storage for a HTTP Response Status.
    public struct Storage<let phraseCount: Int, let codePhraseCount: Int>: StorageProtocol {
        /// Status code of the HTTP Response Status.
        public let code:HTTPResponseStatus.Code
        /// Description/phrase of the HTTP Response Status.
        public let phrase:InlineArray<phraseCount, UInt8>
        public let codePhrase:InlineArray<codePhraseCount, UInt8>

        public init(
            code: HTTPResponseStatus.Code,
            phrase: InlineArray<phraseCount, UInt8>,
            codePhrase: InlineArray<codePhraseCount, UInt8>
        ) {
            self.code = code
            self.phrase = phrase
            self.codePhrase = codePhrase
        }

        /// Category that the status code falls under.
        @inlinable
        public var category: HTTPResponseStatus.Category {
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
}
extension HTTPResponseStatus.StorageProtocol {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

// MARK: 1xx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("`continue`", 100, "Continue"),
        ("switchingProtocols", 101, "Switching Protocols"),
        ("processing", 102, "Processing"), // deprecated
        ("earlyHints", 103, "Early Hints")
    ])
}

// MARK: 2xx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("ok", 200, "OK"),
        ("created", 201, "Created"),
        ("accepted", 202, "Accepted"),
        ("nonAuthoritativeInformation", 203, "Non-Authoritative Information"),
        ("noContent", 204, "No Content"),
        ("resetContent", 205, "Reset Content"),
        ("partialContent", 206, "Partial Content"),
        ("multiStatus", 207, "Multi-Status"),
        ("alreadyReported", 208, "Already Reported"),
        ("imUsed", 226, "IM Used")
    ])
}

// MARK: 3xx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("multipleChoices", 300, "Multiple Choices"),
        ("movedPermanently", 301, "Moved Permanently"),
        ("found", 302, "Found"),
        ("seeOther", 303, "See Other"),
        ("notModified", 304, "Not Modified"),
        ("useProxy", 305, "Use Proxy"),
        ("temporaryRedirect", 307, "Temporary Redirect"),
        ("permanentRedirect", 308, "Permanent Redirect")
    ])
}

// MARK: 4xx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("badRequest", 400, "Bad Request"),
        ("unauthorized", 401, "Unauthorized"),
        ("paymentRequired", 402, "Payment Required"),
        ("forbidden", 403, "Forbidden"),
        ("notFound", 404, "Not Found"),
        ("methodNotAllowed", 405, "Method Not Allowed"),
        ("notAcceptable", 406, "Not Acceptable"),
        ("proxyAuthenticationRequired", 407, "Proxy Authentication Required"),
        ("requestTimeout", 408, "Request Timeout"),
        ("conflict", 409, "Conflict"),
        ("gone", 410, "Gone"),
        ("lengthRequired", 411, "Length Required"),
        ("preconditionFailed", 412, "Precondition Failed"),
        ("payloadTooLarge", 413, "Payload Too Large"),
        ("uriTooLong", 414, "URI Too Long"),
        ("unsupportedMediaType", 415, "Unsupported Media Type"),
        ("rangeNotSatisfiable", 416, "Range Not Satisfiable"),
        ("expectationFailed", 417, "Expectation Failed"),
        ("imATeapot", 418, "I'm a teapot"),
        ("misdirectedRequest", 421, "Misdirected Request"),
        ("unprocessableContent", 422, "Unprocessable Content"),
        ("locked", 423, "Locked"),
        ("failedDependency", 424, "Failed Dependency"),
        ("tooEarly", 425, "Too Early"),
        ("upgradeRequired", 426, "Upgrade Required"),
        ("preconditionRequired", 428, "Precondition Required"),
        ("tooManyRequests", 429, "Too Many Requests"),
        ("requestHeaderFieldsTooLarge", 431, "Request Header Fields Too Large"),
        ("unavailableForLegalReasons", 451, "Unavailable For Legal Reasons")
    ])
}

// MARK: 5xx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("internalServerError", 500, "Internal Server Error"),
        ("notImplemented", 501, "Not Implemented"),
        ("badGateway", 502, "Bad Gateway"),
        ("serviceUnavailable", 503, "Service Unavailable"),
        ("gatewayTimeout", 504, "Gateway Timeout"),
        ("httpVersionNotSupported", 505, "HTTP Version Not Supported"),
        ("variantAlsoNegotiates", 506, "Variant Also Negotiates"),
        ("insufficientStorage", 507, "Insufficient Storage"),
        ("loopDetected", 508, "Loop Detected"),
        ("notExtended", 510, "Not Extended"),
        ("networkAuthenticationRequired", 511, "Network Authentication Required")
    ])
}

// MARK: Unofficial
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("thisIsFine", 218, "This is fine"),
        ("pageExpired", 419, "Page Expired"),
        ("methodFailure", 420, "Method Failure"),
        ("enhanceYourCalm", 420, "Enhance Your Calm"),
        ("shopifySecurityRejection", 430, "Shopify Security Rejection"),
        ("blockedByWindowsParentalControls", 450, "Blocked by Windows Parental Controls"),
        ("invalidToken", 498, "Invalid Token"),
        ("tokenRequired", 499, "Token Required"),
        ("bandwidthLimitExceeded", 509, "Bandwidth Limit Exceeded"),
        ("siteIsOverloaded", 529, "Site is overloaded"),
        ("siteIsFrozen", 530, "Site is frozen"),
        ("originDNSError", 530, "Origin DNS Error"),
        ("temporarilyDisabled", 540, "Temporarily Disabled"),
        ("networkReadTimeoutError", 598, "Network read timeout error"),
        ("networkConnectTimeoutError", 599, "Network Connect Timeout Error"),
        ("unexpectedToken", 783, "Unexpected Token"),
        ("nonStandard", 999, "Non-standard"),
    ])
}

// MARK: Internet Information Services
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("loginTimeout", 440, "Login Time-out"),
        ("retryWith", 449, "Retry With"),
        ("redirect", 451, "Redirect")
    ])
}

// MARK: nginx
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("noResponse", 444, "No Response"),
        ("requestHeaderTooLarge", 494, "Request header too large"),
        ("sslCertificateError", 495, "SSL Certificate Error"),
        ("sslCertificateRequired", 496, "SSL Certificate Required"),
        ("httpRequestSendToHTTPSPort", 497, "HTTP Request Sent to HTTPS Port"),
        ("clientClosedRequest", 499, "Client Closed Request")
    ])
}

// MARK: Cloudflare
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("webServerReturnedAnUnknownError", 520, "Web Server Returned an Unknown Error"),
        ("webServerIsDown", 521, "Web Server Is Down"),
        ("connectionTimedOut", 522, "Connection Timed Out"),
        ("originIsUnreachable", 523, "Origin Is Unreachable"),
        ("aTimeoutOccurred", 524, "A Timeout Occurred"),
        ("sslHandshakeFailed", 525, "SSL Handshake Failed"),
        ("invalidSSLCertificate", 526, "Invalid SSL Certificate"),
        ("issueResolvingOriginHostname", 530, "Issue Resolving Origin Hostname")
    ])
}

// MARK: AWS Elastic Load Balancing
extension HTTPResponseStatus {
    #httpResponseStatuses([
        ("_000", 000, ""),
        ("_460", 460, ""),
        ("_463", 463, ""),
        ("_464", 464, ""),
        ("_561", 561, "")
    ])
}

/*
// MARK: CustomDebugStringConvertible
extension HTTPResponseStatus: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        "HTTPResponseStatus.\(rawValue)"
    }
}*/

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
}

#if canImport(SwiftSyntax)

import SwiftSyntax

// MARK: SwiftSyntax
extension HTTPResponseStatus {
    public static func parse(expr: ExprSyntax) -> (any Self.StorageProtocol)? {
        guard let member = expr.memberAccess,
            member.declName.baseName.text == "code",
            let base = member.base?.memberAccess,
            base.base?.as(DeclReferenceExprSyntax.self)?.baseName.text == "HTTPResponseStatus"
        else {
            return nil
        }
        return parse(staticName: base.declName.baseName.text)
    }
}
#endif


// MARK: Parse
extension HTTPResponseStatus {
    public static func parse(staticName: String) -> (any Self.StorageProtocol)? {
        switch staticName {
        case "continue": Self.continue
        case "switchingProtocols": Self.switchingProtocols
        case "processing": Self.processing
        case "earlyHints": Self.earlyHints

        case "ok": Self.ok
        case "created": Self.created
        case "accepted": Self.accepted
        case "nonAuthoritativeInformation": Self.nonAuthoritativeInformation
        case "noContent": Self.noContent
        case "resetContent": Self.resetContent
        case "partialContent": Self.partialContent
        case "multiStatus": Self.multiStatus
        case "alreadyReported": Self.alreadyReported
        case "imUsed": Self.imUsed

        case "multipleChoices": Self.multipleChoices
        case "movedPermanently": Self.movedPermanently
        case "found": Self.found
        case "seeOther": Self.seeOther
        case "notModified": Self.notModified
        case "useProxy": Self.useProxy
        case "temporaryRedirect": Self.temporaryRedirect
        case "permanentRedirect": Self.permanentRedirect

        case "badRequest": Self.badRequest
        case "unauthorized": Self.unauthorized
        case "paymentRequired": Self.paymentRequired
        case "forbidden": Self.forbidden
        case "notFound": Self.notFound
        case "methodNotAllowed": Self.methodNotAllowed
        case "notAcceptable": Self.notAcceptable
        case "proxyAuthenticationRequired": Self.proxyAuthenticationRequired
        case "requestTimeout": Self.requestTimeout
        case "conflict": Self.conflict
        case "gone": Self.gone
        case "lengthRequired": Self.lengthRequired
        case "preconditionFailed": Self.preconditionFailed
        case "payloadTooLarge": Self.payloadTooLarge
        case "uriTooLong": Self.uriTooLong
        case "unsupportedMediaType": Self.unsupportedMediaType
        case "rangeNotSatisfiable": Self.rangeNotSatisfiable
        case "expectationFailed": Self.expectationFailed
        case "imATeapot": Self.imATeapot
        case "misdirectedRequest": Self.misdirectedRequest
        case "unprocessableContent": Self.unprocessableContent
        case "locked": Self.locked
        case "failedDependency": Self.failedDependency
        case "tooEarly": Self.tooEarly
        case "upgradeRequired": Self.upgradeRequired
        case "preconditionRequired": Self.preconditionRequired
        case "tooManyRequests": Self.tooManyRequests
        case "requestHeaderFieldsTooLarge": Self.requestHeaderFieldsTooLarge
        case "unavailableForLegalReasons": Self.unavailableForLegalReasons

        case "internalServerError": Self.internalServerError
        case "notImplemented": Self.notImplemented
        case "badGateway": Self.badGateway
        case "serviceUnavailable": Self.serviceUnavailable
        case "gatewayTimeout": Self.gatewayTimeout
        case "httpVersionNotSupported": Self.httpVersionNotSupported
        case "variantAlsoNegotiates": Self.variantAlsoNegotiates
        case "insufficientStorage": Self.insufficientStorage
        case "loopDetected": Self.loopDetected
        case "notExtended": Self.notExtended
        case "networkAuthenticationRequired": Self.networkAuthenticationRequired

        // TODO: support unofficial and others
        default: nil
        }
    }
}
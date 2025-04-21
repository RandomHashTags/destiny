//
//  HTTPResponseStatus.swift
//
//
//  Created by Evan Anderson on 1/20/25.
//

import SwiftSyntax

// MARK: HTTPResponseStatus
/// HTTP Status Codes. 
/// 
/// Useful links:
/// - Standard Registry: https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
/// - Wikipedia: https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
public enum HTTPResponseStatus {
    public typealias Code = Int
}

// MARK: Storage
extension HTTPResponseStatus {
    public protocol StorageProtocol : Hashable, Sendable {
        associatedtype ConcreteCodePhrase:InlineArrayProtocol

        var code : Int { get }
        var codePhrase : ConcreteCodePhrase { get }
        var category : HTTPResponseStatus.Category { get }
    }
    public struct Storage<let phraseCount: Int, let codePhraseCount: Int> : StorageProtocol {
        public let code:Int
        public let phrase:InlineArray<phraseCount, UInt8>
        public let codePhrase:InlineArray<codePhraseCount, UInt8>

        public init(
            code: Int,
            phrase: InlineArray<phraseCount, UInt8>,
            codePhrase: InlineArray<codePhraseCount, UInt8>
        ) {
            self.code = code
            self.phrase = phrase
            self.codePhrase = codePhrase
        }

        /// Category that the status code falls under.
        @inlinable
        public var category : HTTPResponseStatus.Category {
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
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.100
    public static let `continue` = #httpResponseStatus(code: 100, phrase: "Continue")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.101
    public static let switchingProtocols = #httpResponseStatus(code: 101, phrase: "Switching Protocols")

    @available(*, deprecated, message: "Deprecated")
    public static let processing = #httpResponseStatus(code: 102, phrase: "Processing")

    public static let earlyHints = #httpResponseStatus(code: 103, phrase: "Early Hints")
}

// MARK: 2xx
extension HTTPResponseStatus {
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.200
    public static let ok = #httpResponseStatus(code: 200, phrase: "OK")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.201
    public static let created = #httpResponseStatus(code: 201, phrase: "Created")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.202
    public static let accepted = #httpResponseStatus(code: 202, phrase: "Accepted")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.203
    public static let nonAuthoritativeInformation = #httpResponseStatus(code: 203, phrase: "Non-Authoritative Information")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.204
    public static let noContent = #httpResponseStatus(code: 204, phrase: "No Content")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.205
    public static let resetContent = #httpResponseStatus(code: 205, phrase: "Reset Content")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.206
    public static let partialContent = #httpResponseStatus(code: 206, phrase: "Partial Content")
    
    public static let multiStatus = #httpResponseStatus(code: 207, phrase: "Multi-Status")

    public static let alreadyReported = #httpResponseStatus(code: 208, phrase: "Already Reported")

    public static let imUsed = #httpResponseStatus(code: 226, phrase: "IM Used")
}

// MARK: 3xx
extension HTTPResponseStatus {
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.300
    public static let multipleChoices = #httpResponseStatus(code: 300, phrase: "Multiple Choices")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.301
    public static let movedPermanently = #httpResponseStatus(code: 301, phrase: "Moved Permanently")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.302
    public static let found = #httpResponseStatus(code: 302, phrase: "Found")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.303
    public static let seeOther = #httpResponseStatus(code: 303, phrase: "See Other")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.304
    public static let notModified = #httpResponseStatus(code: 304, phrase: "Not Modified")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.305
    public static let useProxy = #httpResponseStatus(code: 305, phrase: "Use Proxy")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.307
    public static let temporaryRedirect = #httpResponseStatus(code: 307, phrase: "Temporary Redirect")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.308
    public static let permanentRedirect = #httpResponseStatus(code: 308, phrase: "Permanent Redirect")
}

// MARK: 4xx
extension HTTPResponseStatus {
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.400
    public static let badRequest = #httpResponseStatus(code: 400, phrase: "Bad Request")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.401
    public static let unauthorized = #httpResponseStatus(code: 401, phrase: "Unauthorized")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.402
    public static let paymentRequired = #httpResponseStatus(code: 402, phrase: "Payment Required")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.403
    public static let forbidden = #httpResponseStatus(code: 403, phrase: "Forbidden")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.404
    public static let notFound = #httpResponseStatus(code: 404, phrase: "Not Found")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.405
    public static let methodNotAllowed = #httpResponseStatus(code: 405, phrase: "Method Not Allowed")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.406
    public static let notAcceptable = #httpResponseStatus(code: 406, phrase: "Not Acceptable")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.407
    public static let proxyAuthenticationRequired = #httpResponseStatus(code: 407, phrase: "Proxy Authentication Required")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.408
    public static let requestTimeout = #httpResponseStatus(code: 408, phrase: "Request Timeout")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.409
    public static let conflict = #httpResponseStatus(code: 409, phrase: "Conflict")
    
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.410
    public static let gone = #httpResponseStatus(code: 410, phrase: "Gone")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.411
    public static let lengthRequired = #httpResponseStatus(code: 411, phrase: "Length Required")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.412
    public static let preconditionFailed = #httpResponseStatus(code: 412, phrase: "Precondition Failed")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.413
    public static let payloadTooLarge = #httpResponseStatus(code: 413, phrase: "Payload Too Large")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.414
    public static let uriTooLong = #httpResponseStatus(code: 414, phrase: "URI Too Long")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.415
    public static let unsupportedMediaType = #httpResponseStatus(code: 415, phrase: "Unsupported Media Type")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.416
    public static let rangeNotSatisfiable = #httpResponseStatus(code: 416, phrase: "Range Not Satisfiable")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.417
    public static let expectationFailed = #httpResponseStatus(code: 417, phrase: "Expectation Failed")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.418
    public static let imATeapot = #httpResponseStatus(code: 418, phrase: "I'm a teapot")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.421
    public static let misdirectedRequest = #httpResponseStatus(code: 421, phrase: "Misdirected Request")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.422
    public static let unprocessableContent = #httpResponseStatus(code: 422, phrase: "Unprocessable Content")

    /// - Code: 423
    public static let locked = #httpResponseStatus(code: 423, phrase: "Locked")

    /// - Code: 424
    public static let failedDependency = #httpResponseStatus(code: 424, phrase: "Failed Dependency")

    /// - Code: 425
    public static let tooEarly = #httpResponseStatus(code: 425, phrase: "Too Early")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.426
    public static let upgradeRequired = #httpResponseStatus(code: 426, phrase: "Upgrade Required")

    /// - Code: 428
    public static let preconditionRequired = #httpResponseStatus(code: 428, phrase: "Precondition Required")

    /// - Code: 429
    public static let tooManyRequests = #httpResponseStatus(code: 429, phrase: "Too Many Requests")

    /// - Code: 431
    public static let requestHeaderFieldsTooLarge = #httpResponseStatus(code: 431, phrase: "Request Header Fields Too Large")

    /// - Code: 451
    public static let unavailableForLegalReasons = #httpResponseStatus(code: 451, phrase: "Unavailable For Legal Reasons")
}

// MARK: 5xx
extension HTTPResponseStatus {
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.500
    public static let internalServerError = #httpResponseStatus(code: 500, phrase: "Internal Server Error")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.501
    public static let notImplemented = #httpResponseStatus(code: 501, phrase: "Not Implemented")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.502
    public static let badGateway = #httpResponseStatus(code: 502, phrase: "Bad Gateway")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.503
    public static let serviceUnavailable = #httpResponseStatus(code: 503, phrase: "Service Unavailable")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.504
    public static let gatewayTimeout = #httpResponseStatus(code: 504, phrase: "Gateway Timeout")

    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.505
    public static let httpVersionNotSupported = #httpResponseStatus(code: 505, phrase: "HTTP Version Not Supported")

    /// - Code: 506
    public static let variantAlsoNegotiates = #httpResponseStatus(code: 506, phrase: "Variant Also Negotiates")

    /// - Code: 507
    public static let insufficientStorage = #httpResponseStatus(code: 507, phrase: "Insufficient Storage")

    /// - Code: 508
    public static let loopDetected = #httpResponseStatus(code: 508, phrase: "Loop Detected")

    /// - Code: 519
    public static let notExtended = #httpResponseStatus(code: 510, phrase: "Not Extended")

    /// - Code: 511
    public static let networkAuthenticationRequired = #httpResponseStatus(code: 511, phrase: "Network Authentication Required")
}

// MARK: Unofficial
extension HTTPResponseStatus {
    /// - Code: 218
    public static let thisIsFine = #httpResponseStatus(code: 218, phrase: "This is fine")

    /// - Code: 419
    public static let pageExpired = #httpResponseStatus(code: 419, phrase: "Page Expired")

    /// - Code: 420
    public static let methodFailure = #httpResponseStatus(code: 420, phrase: "Method Failure")

    /// - Code: 420
    public static let enhanceYourCalm = #httpResponseStatus(code: 420, phrase: "Enhance Your Calm")

    /// - Code: 430
    public static let shopifySecurityRejection = #httpResponseStatus(code: 430, phrase: "Shopify Security Rejection")

    /// - Code: 450
    public static let blockedByWindowsParentalControls = #httpResponseStatus(code: 450, phrase: "Blocked by Windows Parental Controls")

    /// - Code: 498
    public static let invalidToken = #httpResponseStatus(code: 498, phrase: "Invalid Token")

    /// - Code: 499
    public static let tokenRequired = #httpResponseStatus(code: 499, phrase: "Token Required")

    /// - Code: 509
    public static let bandwidthLimitExceeded = #httpResponseStatus(code: 509, phrase: "Bandwidth Limit Exceeded")

    /// - Code: 529
    public static let siteIsOverloaded = #httpResponseStatus(code: 529, phrase: "Site is overloaded")

    /// - Code: 530
    public static let siteIsFrozen = #httpResponseStatus(code: 530, phrase: "Site is frozen")

    /// - Code: 530
    public static let originDNSError = #httpResponseStatus(code: 530, phrase: "Origin DNS Error")

    /// - Code: 540
    public static let temporarityDisabled = #httpResponseStatus(code: 540, phrase: "Temporarily Disabled")

    /// - Code: 598
    public static let networkReadTimeoutError = #httpResponseStatus(code: 598, phrase: "Network read timeout error")

    /// - Code: 599
    public static let networkConnectTimeoutError = #httpResponseStatus(code: 599, phrase: "Network Connect Timeout Error")

    /// - Code: 783
    public static let unexpectedToken = #httpResponseStatus(code: 783, phrase: "Unexpected Token")

    /// - Code: 999
    public static let nonStandard = #httpResponseStatus(code: 999, phrase: "Non-standard")
}

// MARK: Internet Information Services
extension HTTPResponseStatus {
    /// - Code: 440
    public static let loginTimeout = #httpResponseStatus(code: 440, phrase: "Login Time-out")

    /// - Code: 449
    public static let retryWith = #httpResponseStatus(code: 449, phrase: "Retry With")

    /// - Code: 451
    public static let redirect = #httpResponseStatus(code: 451, phrase: "Redirect")
}

// MARK: nginx
extension HTTPResponseStatus {
    /// - Code: 444
    public static let noResponse = #httpResponseStatus(code: 444, phrase: "No Response")

    /// - Code: 494
    public static let requestHeaderTooLarge = #httpResponseStatus(code: 494, phrase: "Request header too large")

    /// - Code: 495
    public static let sslCertificateError = #httpResponseStatus(code: 495, phrase: "SSL Certificate Error")

    /// - Code: 496
    public static let sslCertificateRequired = #httpResponseStatus(code: 496, phrase: "SSL Certificate Required")

    /// - Code: 497
    public static let httpRequestSendToHTTPSPort = #httpResponseStatus(code: 497, phrase: "HTTP Request Sent to HTTPS Port")

    /// - Code: 499
    public static let clientClosedRequest = #httpResponseStatus(code: 499, phrase: "Client Closed Request")
}

// MARK: Cloudflare
extension HTTPResponseStatus {
    /// - Code: 520
    public static let webServerReturnedAnUnknownError = #httpResponseStatus(code: 520, phrase: "Web Server Returned an Unknown Error")

    /// - Code: 521
    public static let webServerIsDown = #httpResponseStatus(code: 521, phrase: "Web Server Is Down")

    /// - Code: 522
    public static let connectionTimedOut = #httpResponseStatus(code: 522, phrase: "Connection Timed Out")

    /// - Code: 523
    public static let originIsUnreachable = #httpResponseStatus(code: 523, phrase: "Origin Is Unreachable")

    /// - Code: 524
    public static let aTimeoutOccurred = #httpResponseStatus(code: 524, phrase: "A Timeout Occurred")

    /// - Code: 525
    public static let sslHandshakeFailed = #httpResponseStatus(code: 525, phrase: "SSL Handshake Failed")

    /// - Code: 526
    public static let invalidSSLCertificate = #httpResponseStatus(code: 526, phrase: "Invalid SSL Certificate")

    /// - Code: 530
    public static let issueResolvingOriginHostname = #httpResponseStatus(code: 530, phrase: "Issue Resolving Origin Hostname")
}

// MARK: AWS Elastic Load Balancing
extension HTTPResponseStatus {
    /// - Code: 000
    public static let _000 = #httpResponseStatus(code: 000, phrase: "")

    /// - Code: 460
    public static let _460 = #httpResponseStatus(code: 460, phrase: "")

    /// - Code: 463
    public static let _463 = #httpResponseStatus(code: 463, phrase: "")

    /// - Code: 464
    public static let _464 = #httpResponseStatus(code: 464, phrase: "")

    /// - Code: 561
    public static let _561 = #httpResponseStatus(code: 561, phrase: "")
}

/*
// MARK: CustomDebugStringConvertible
extension HTTPResponseStatus : CustomDebugStringConvertible {
    @inlinable
    public var debugDescription : String {
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
// MARK: SwiftSyntax
extension HTTPResponseStatus {
    public static func parse(expr: ExprSyntax) -> (any HTTPResponseStatus.StorageProtocol)? {
        guard let member = expr.as(MemberAccessExprSyntax.self),
            member.declName.baseName.text == "code",
            let base = member.base?.as(MemberAccessExprSyntax.self),
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
    public static func parse(staticName: String) -> (any HTTPResponseStatus.StorageProtocol)? {
        switch staticName {
        case "continue": HTTPResponseStatus.continue
        case "switchingProtocols": HTTPResponseStatus.switchingProtocols
        case "processing": HTTPResponseStatus.processing
        case "earlyHints": HTTPResponseStatus.earlyHints

        case "ok": HTTPResponseStatus.ok
        case "created": HTTPResponseStatus.created
        case "accepted": HTTPResponseStatus.accepted
        case "nonAuthoritativeInformation": HTTPResponseStatus.nonAuthoritativeInformation
        case "noContent": HTTPResponseStatus.noContent
        case "resetContent": HTTPResponseStatus.resetContent
        case "partialContent": HTTPResponseStatus.partialContent
        case "multiStatus": HTTPResponseStatus.multiStatus
        case "alreadyReported": HTTPResponseStatus.alreadyReported
        case "imUsed": HTTPResponseStatus.imUsed

        case "multipleChoices": HTTPResponseStatus.multipleChoices
        case "movedPermanently": HTTPResponseStatus.movedPermanently
        case "found": HTTPResponseStatus.found
        case "seeOther": HTTPResponseStatus.seeOther
        case "notModified": HTTPResponseStatus.notModified
        case "useProxy": HTTPResponseStatus.useProxy
        case "temporaryRedirect": HTTPResponseStatus.temporaryRedirect
        case "permanentRedirect": HTTPResponseStatus.permanentRedirect

        case "badRequest": HTTPResponseStatus.badRequest
        case "unauthorized": HTTPResponseStatus.unauthorized
        case "paymentRequired": HTTPResponseStatus.paymentRequired
        case "forbidden": HTTPResponseStatus.forbidden
        case "notFound": HTTPResponseStatus.notFound
        case "methodNotAllowed": HTTPResponseStatus.methodNotAllowed
        case "notAcceptable": HTTPResponseStatus.notAcceptable
        case "proxyAuthenticationRequired": HTTPResponseStatus.proxyAuthenticationRequired
        case "requestTimeout": HTTPResponseStatus.requestTimeout
        case "conflict": HTTPResponseStatus.conflict
        case "gone": HTTPResponseStatus.gone
        case "lengthRequired": HTTPResponseStatus.lengthRequired
        case "preconditionFailed": HTTPResponseStatus.preconditionFailed
        case "payloadTooLarge": HTTPResponseStatus.payloadTooLarge
        case "uriTooLong": HTTPResponseStatus.uriTooLong
        case "unsupportedMediaType": HTTPResponseStatus.unsupportedMediaType
        case "rangeNotSatisfiable": HTTPResponseStatus.rangeNotSatisfiable
        case "expectationFailed": HTTPResponseStatus.expectationFailed
        case "imATeapot": HTTPResponseStatus.imATeapot
        case "misdirectedRequest": HTTPResponseStatus.misdirectedRequest
        case "unprocessableContent": HTTPResponseStatus.unprocessableContent
        case "locked": HTTPResponseStatus.locked
        case "failedDependency": HTTPResponseStatus.failedDependency
        case "tooEarly": HTTPResponseStatus.tooEarly
        case "upgradeRequired": HTTPResponseStatus.upgradeRequired
        case "preconditionRequired": HTTPResponseStatus.preconditionRequired
        case "tooManyRequests": HTTPResponseStatus.tooManyRequests
        case "requestHeaderFieldsTooLarge": HTTPResponseStatus.requestHeaderFieldsTooLarge
        case "unavailableForLegalReasons": HTTPResponseStatus.unavailableForLegalReasons

        case "internalServerError": HTTPResponseStatus.internalServerError
        case "notImplemented": HTTPResponseStatus.notImplemented
        case "badGateway": HTTPResponseStatus.badGateway
        case "serviceUnavailable": HTTPResponseStatus.serviceUnavailable
        case "gatewayTimeout": HTTPResponseStatus.gatewayTimeout
        case "httpVersionNotSupported": HTTPResponseStatus.httpVersionNotSupported
        case "variantAlsoNegotiates": HTTPResponseStatus.variantAlsoNegotiates
        case "insufficientStorage": HTTPResponseStatus.insufficientStorage
        case "loopDetected": HTTPResponseStatus.loopDetected
        case "notExtended": HTTPResponseStatus.notExtended
        case "networkAuthenticationRequired": HTTPResponseStatus.networkAuthenticationRequired

        // TODO: support unofficial and others
        default: nil
        }
    }
}
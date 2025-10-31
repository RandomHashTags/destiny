
#if HTTPNonStandardResponseStatuses

public enum HTTPNonStandardResponseStatus: Sendable {
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
    case temporarilyDisabled
    case networkReadTimeoutError
    case networkConnectTimeoutError
    case unexpectedToken
    case nonStandard
    case loginTimeout
    case retryWith
    case redirect
    case noResponse
    case requestHeaderTooLarge
    case sslCertificateError
    case sslCertificateRequired
    case httpRequestSendToHTTPSPort
    case clientClosedRequest
    case webServerReturnedAnUnknownError
    case webServerIsDown
    case connectionTimedOut
    case originIsUnreachable
    case aTimeoutOccurred
    case sslHandshakeFailed
    case invalidSSLCertificate
    case issueResolvingOriginHostname
    case _000
    case _460
    case _463
    case _464
    case _561

    public var code: UInt16 {
        switch self {
        case .thisIsFine: 218
        case .pageExpired: 419
        case .methodFailure: 420
        case .enhanceYourCalm: 420
        case .shopifySecurityRejection: 430
        case .blockedByWindowsParentalControls: 450
        case .invalidToken: 498
        case .tokenRequired: 499
        case .bandwidthLimitExceeded: 509
        case .siteIsOverloaded: 529
        case .siteIsFrozen: 530
        case .originDNSError: 530
        case .temporarilyDisabled: 540
        case .networkReadTimeoutError: 598
        case .networkConnectTimeoutError: 599
        case .unexpectedToken: 783
        case .nonStandard: 999
        case .loginTimeout: 440
        case .retryWith: 449
        case .redirect: 451
        case .noResponse: 444
        case .requestHeaderTooLarge: 494
        case .sslCertificateError: 495
        case .sslCertificateRequired: 496
        case .httpRequestSendToHTTPSPort: 497
        case .clientClosedRequest: 499
        case .webServerReturnedAnUnknownError: 520
        case .webServerIsDown: 521
        case .connectionTimedOut: 522
        case .originIsUnreachable: 523
        case .aTimeoutOccurred: 524
        case .sslHandshakeFailed: 525
        case .invalidSSLCertificate: 526
        case .issueResolvingOriginHostname: 530
        case ._000: 0
        case ._460: 460
        case ._463: 463
        case ._464: 464
        case ._561: 561
        }
    }
}

#if HTTPNonStandardResponseStatusRawValues
extension HTTPNonStandardResponseStatus: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "thisIsFine": self = .thisIsFine
        case "pageExpired": self = .pageExpired
        case "methodFailure": self = .methodFailure
        case "enhanceYourCalm": self = .enhanceYourCalm
        case "shopifySecurityRejection": self = .shopifySecurityRejection
        case "blockedByWindowsParentalControls": self = .blockedByWindowsParentalControls
        case "invalidToken": self = .invalidToken
        case "tokenRequired": self = .tokenRequired
        case "bandwidthLimitExceeded": self = .bandwidthLimitExceeded
        case "siteIsOverloaded": self = .siteIsOverloaded
        case "siteIsFrozen": self = .siteIsFrozen
        case "originDNSError": self = .originDNSError
        case "temporarilyDisabled": self = .temporarilyDisabled
        case "networkReadTimeoutError": self = .networkReadTimeoutError
        case "networkConnectTimeoutError": self = .networkConnectTimeoutError
        case "unexpectedToken": self = .unexpectedToken
        case "nonStandard": self = .nonStandard
        case "loginTimeout": self = .loginTimeout
        case "retryWith": self = .retryWith
        case "redirect": self = .redirect
        case "noResponse": self = .noResponse
        case "requestHeaderTooLarge": self = .requestHeaderTooLarge
        case "sslCertificateError": self = .sslCertificateError
        case "sslCertificateRequired": self = .sslCertificateRequired
        case "httpRequestSendToHTTPSPort": self = .httpRequestSendToHTTPSPort
        case "clientClosedRequest": self = .clientClosedRequest
        case "webServerReturnedAnUnknownError": self = .webServerReturnedAnUnknownError
        case "webServerIsDown": self = .webServerIsDown
        case "connectionTimedOut": self = .connectionTimedOut
        case "originIsUnreachable": self = .originIsUnreachable
        case "aTimeoutOccurred": self = .aTimeoutOccurred
        case "sslHandshakeFailed": self = .sslHandshakeFailed
        case "invalidSSLCertificate": self = .invalidSSLCertificate
        case "issueResolvingOriginHostname": self = .issueResolvingOriginHostname
        case "_000": self = ._000
        case "_460": self = ._460
        case "_463": self = ._463
        case "_464": self = ._464
        case "_561": self = ._561
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .thisIsFine: "thisIsFine"
        case .pageExpired: "pageExpired"
        case .methodFailure: "methodFailure"
        case .enhanceYourCalm: "enhanceYourCalm"
        case .shopifySecurityRejection: "shopifySecurityRejection"
        case .blockedByWindowsParentalControls: "blockedByWindowsParentalControls"
        case .invalidToken: "invalidToken"
        case .tokenRequired: "tokenRequired"
        case .bandwidthLimitExceeded: "bandwidthLimitExceeded"
        case .siteIsOverloaded: "siteIsOverloaded"
        case .siteIsFrozen: "siteIsFrozen"
        case .originDNSError: "originDNSError"
        case .temporarilyDisabled: "temporarilyDisabled"
        case .networkReadTimeoutError: "networkReadTimeoutError"
        case .networkConnectTimeoutError: "networkConnectTimeoutError"
        case .unexpectedToken: "unexpectedToken"
        case .nonStandard: "nonStandard"
        case .loginTimeout: "loginTimeout"
        case .retryWith: "retryWith"
        case .redirect: "redirect"
        case .noResponse: "noResponse"
        case .requestHeaderTooLarge: "requestHeaderTooLarge"
        case .sslCertificateError: "sslCertificateError"
        case .sslCertificateRequired: "sslCertificateRequired"
        case .httpRequestSendToHTTPSPort: "httpRequestSendToHTTPSPort"
        case .clientClosedRequest: "clientClosedRequest"
        case .webServerReturnedAnUnknownError: "webServerReturnedAnUnknownError"
        case .webServerIsDown: "webServerIsDown"
        case .connectionTimedOut: "connectionTimedOut"
        case .originIsUnreachable: "originIsUnreachable"
        case .aTimeoutOccurred: "aTimeoutOccurred"
        case .sslHandshakeFailed: "sslHandshakeFailed"
        case .invalidSSLCertificate: "invalidSSLCertificate"
        case .issueResolvingOriginHostname: "issueResolvingOriginHostname"
        case ._000: "_000"
        case ._460: "_460"
        case ._463: "_463"
        case ._464: "_464"
        case ._561: "_561"
        }
    }
}
#endif

#if Protocols

extension HTTPNonStandardResponseStatus: HTTPResponseStatus.StorageProtocol {}

#endif

#endif
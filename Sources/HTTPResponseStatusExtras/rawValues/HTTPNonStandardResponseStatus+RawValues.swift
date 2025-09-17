
import DestinyDefaults

extension HTTPNonStandardResponseStatus: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
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

import DestinyBlueprint

public enum HTTPNonStandardResponseStatus: String, HTTPResponseStatus.StorageProtocol {
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

    @inlinable
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
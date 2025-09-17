
import DestinyDefaults

extension HTTPStandardResponseStatus: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "continue", "`continue`": self = .`continue`
        case "switchingProtocols": self = .switchingProtocols
        case "processing": self = .processing
        case "earlyHints": self = .earlyHints
        case "ok": self = .ok
        case "created": self = .created
        case "accepted": self = .accepted
        case "nonAuthoritativeInformation": self = .nonAuthoritativeInformation
        case "noContent": self = .noContent
        case "resetContent": self = .resetContent
        case "partialContent": self = .partialContent
        case "multiStatus": self = .multiStatus
        case "alreadyReported": self = .alreadyReported
        case "imUsed": self = .imUsed
        case "multipleChoices": self = .multipleChoices
        case "movedPermanently": self = .movedPermanently
        case "found": self = .found
        case "seeOther": self = .seeOther
        case "notModified": self = .notModified
        case "useProxy": self = .useProxy
        case "temporaryRedirect": self = .temporaryRedirect
        case "permanentRedirect": self = .permanentRedirect
        case "badRequest": self = .badRequest
        case "unauthorized": self = .unauthorized
        case "paymentRequired": self = .paymentRequired
        case "forbidden": self = .forbidden
        case "notFound": self = .notFound
        case "methodNotAllowed": self = .methodNotAllowed
        case "notAcceptable": self = .notAcceptable
        case "proxyAuthenticationRequired": self = .proxyAuthenticationRequired
        case "requestTimeout": self = .requestTimeout
        case "conflict": self = .conflict
        case "gone": self = .gone
        case "lengthRequired": self = .lengthRequired
        case "preconditionFailed": self = .preconditionFailed
        case "payloadTooLarge": self = .payloadTooLarge
        case "uriTooLong": self = .uriTooLong
        case "unsupportedMediaType": self = .unsupportedMediaType
        case "rangeNotSatisfiable": self = .rangeNotSatisfiable
        case "expectationFailed": self = .expectationFailed
        case "imATeapot": self = .imATeapot
        case "misdirectedRequest": self = .misdirectedRequest
        case "unprocessableContent": self = .unprocessableContent
        case "locked": self = .locked
        case "failedDependency": self = .failedDependency
        case "tooEarly": self = .tooEarly
        case "upgradeRequired": self = .upgradeRequired
        case "preconditionRequired": self = .preconditionRequired
        case "tooManyRequests": self = .tooManyRequests
        case "requestHeaderFieldsTooLarge": self = .requestHeaderFieldsTooLarge
        case "unavailableForLegalReasons": self = .unavailableForLegalReasons
        case "internalServerError": self = .internalServerError
        case "notImplemented": self = .notImplemented
        case "badGateway": self = .badGateway
        case "serviceUnavailable": self = .serviceUnavailable
        case "gatewayTimeout": self = .gatewayTimeout
        case "httpVersionNotSupported": self = .httpVersionNotSupported
        case "variantAlsoNegotiates": self = .variantAlsoNegotiates
        case "insufficientStorage": self = .insufficientStorage
        case "loopDetected": self = .loopDetected
        case "notExtended": self = .notExtended
        case "networkAuthenticationRequired": self = .networkAuthenticationRequired
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: RawValue {
        switch self {
        case .`continue`: "continue"
        case .switchingProtocols: "switchingProtocols"
        case .processing: "processing"
        case .earlyHints: "earlyHints"
        case .ok: "ok"
        case .created: "created"
        case .accepted: "accepted"
        case .nonAuthoritativeInformation: "nonAuthoritativeInformation"
        case .noContent: "noContent"
        case .resetContent: "resetContent"
        case .partialContent: "partialContent"
        case .multiStatus: "multiStatus"
        case .alreadyReported: "alreadyReported"
        case .imUsed: "imUsed"
        case .multipleChoices: "multipleChoices"
        case .movedPermanently: "movedPermanently"
        case .found: "found"
        case .seeOther: "seeOther"
        case .notModified: "notModified"
        case .useProxy: "useProxy"
        case .temporaryRedirect: "temporaryRedirect"
        case .permanentRedirect: "permanentRedirect"
        case .badRequest: "badRequest"
        case .unauthorized: "unauthorized"
        case .paymentRequired: "paymentRequired"
        case .forbidden: "forbidden"
        case .notFound: "notFound"
        case .methodNotAllowed: "methodNotAllowed"
        case .notAcceptable: "notAcceptable"
        case .proxyAuthenticationRequired: "proxyAuthenticationRequired"
        case .requestTimeout: "requestTimeout"
        case .conflict: "conflict"
        case .gone: "gone"
        case .lengthRequired: "lengthRequired"
        case .preconditionFailed: "preconditionFailed"
        case .payloadTooLarge: "payloadTooLarge"
        case .uriTooLong: "uriTooLong"
        case .unsupportedMediaType: "unsupportedMediaType"
        case .rangeNotSatisfiable: "rangeNotSatisfiable"
        case .expectationFailed: "expectationFailed"
        case .imATeapot: "imATeapot"
        case .misdirectedRequest: "misdirectedRequest"
        case .unprocessableContent: "unprocessableContent"
        case .locked: "locked"
        case .failedDependency: "failedDependency"
        case .tooEarly: "tooEarly"
        case .upgradeRequired: "upgradeRequired"
        case .preconditionRequired: "preconditionRequired"
        case .tooManyRequests: "tooManyRequests"
        case .requestHeaderFieldsTooLarge: "requestHeaderFieldsTooLarge"
        case .unavailableForLegalReasons: "unavailableForLegalReasons"
        case .internalServerError: "internalServerError"
        case .notImplemented: "notImplemented"
        case .badGateway: "badGateway"
        case .serviceUnavailable: "serviceUnavailable"
        case .gatewayTimeout: "gatewayTimeout"
        case .httpVersionNotSupported: "httpVersionNotSupported"
        case .variantAlsoNegotiates: "variantAlsoNegotiates"
        case .insufficientStorage: "insufficientStorage"
        case .loopDetected: "loopDetected"
        case .notExtended: "notExtended"
        case .networkAuthenticationRequired: "networkAuthenticationRequired"
        }
    }
}
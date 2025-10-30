
#if HTTPStandardResponseStatuses

public enum HTTPStandardResponseStatus: Sendable {
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.100
    case `continue`
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.101
    case switchingProtocols
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.102
    case processing
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.103
    case earlyHints
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.200
    case ok
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.201
    case created
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.202
    case accepted
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.203
    case nonAuthoritativeInformation
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.204
    case noContent
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.205
    case resetContent
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.206
    case partialContent
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.207
    case multiStatus
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.208
    case alreadyReported
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.226
    case imUsed
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.300
    case multipleChoices
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.301
    case movedPermanently
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.302
    case found
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.303
    case seeOther
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.304
    case notModified
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.305
    case useProxy
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.307
    case temporaryRedirect
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.308
    case permanentRedirect
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.400
    case badRequest
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.401
    case unauthorized
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.402
    case paymentRequired
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.403
    case forbidden
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.404
    case notFound
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.405
    case methodNotAllowed
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.406
    case notAcceptable
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.407
    case proxyAuthenticationRequired
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.408
    case requestTimeout
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.409
    case conflict
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.410
    case gone
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.411
    case lengthRequired
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.412
    case preconditionFailed
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.413
    case payloadTooLarge
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.414
    case uriTooLong
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.415
    case unsupportedMediaType
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.416
    case rangeNotSatisfiable
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.417
    case expectationFailed
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.418
    case imATeapot
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.421
    case misdirectedRequest
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.422
    case unprocessableContent
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.423
    case locked
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.424
    case failedDependency
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.425
    case tooEarly
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.426
    case upgradeRequired
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.428
    case preconditionRequired
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.429
    case tooManyRequests
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.431
    case requestHeaderFieldsTooLarge
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.451
    case unavailableForLegalReasons
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.500
    case internalServerError
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.501
    case notImplemented
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.502
    case badGateway
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.503
    case serviceUnavailable
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.504
    case gatewayTimeout
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.505
    case httpVersionNotSupported
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.506
    case variantAlsoNegotiates
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.507
    case insufficientStorage
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.508
    case loopDetected
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.510
    case notExtended
    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.511
    case networkAuthenticationRequired

    public var code: UInt16 {
        switch self {
        case .`continue`: 100
        case .switchingProtocols: 101
        case .processing: 102
        case .earlyHints: 103
        case .ok: 200
        case .created: 201
        case .accepted: 202
        case .nonAuthoritativeInformation: 203
        case .noContent: 204
        case .resetContent: 205
        case .partialContent: 206
        case .multiStatus: 207
        case .alreadyReported: 208
        case .imUsed: 226
        case .multipleChoices: 300
        case .movedPermanently: 301
        case .found: 302
        case .seeOther: 303
        case .notModified: 304
        case .useProxy: 305
        case .temporaryRedirect: 307
        case .permanentRedirect: 308
        case .badRequest: 400
        case .unauthorized: 401
        case .paymentRequired: 402
        case .forbidden: 403
        case .notFound: 404
        case .methodNotAllowed: 405
        case .notAcceptable: 406
        case .proxyAuthenticationRequired: 407
        case .requestTimeout: 408
        case .conflict: 409
        case .gone: 410
        case .lengthRequired: 411
        case .preconditionFailed: 412
        case .payloadTooLarge: 413
        case .uriTooLong: 414
        case .unsupportedMediaType: 415
        case .rangeNotSatisfiable: 416
        case .expectationFailed: 417
        case .imATeapot: 418
        case .misdirectedRequest: 421
        case .unprocessableContent: 422
        case .locked: 423
        case .failedDependency: 424
        case .tooEarly: 425
        case .upgradeRequired: 426
        case .preconditionRequired: 428
        case .tooManyRequests: 429
        case .requestHeaderFieldsTooLarge: 431
        case .unavailableForLegalReasons: 451
        case .internalServerError: 500
        case .notImplemented: 501
        case .badGateway: 502
        case .serviceUnavailable: 503
        case .gatewayTimeout: 504
        case .httpVersionNotSupported: 505
        case .variantAlsoNegotiates: 506
        case .insufficientStorage: 507
        case .loopDetected: 508
        case .notExtended: 510
        case .networkAuthenticationRequired: 511
        }
    }
}

#if HTTPStandardResponseStatusRawValues
extension HTTPStandardResponseStatus: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "`continue`", "continue": self = .`continue`
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
#endif

#if canImport(DestinyBlueprint)

import DestinyBlueprint

extension HTTPStandardResponseStatus: HTTPResponseStatus.StorageProtocol {}

#endif

#endif

import DestinyBlueprint

public enum HTTPStandardResponseStatus: String, HTTPResponseStatus.StorageProtocol {
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

    #if Inlinable
    @inlinable
    #endif
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    #if Inlinable
    @inlinable
    #endif
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
//
//  HTTPResponseStatusParse.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes

public extension HTTPResponse.Status {
    // MARK: Parse by code
    var caseName : String? {
        switch code {
        case 100: return "continue"
        case 101: return "switchingProtocols"
        case 102: return "earlyHints"

        case 200: return "ok"
        case 201: return "created"
        case 202: return "accepted"
        case 203: return "nonAuthoritativeInformation"
        case 204: return "noContent"
        case 205: return "resetContent"
        case 206: return "partialContent"

        case 300: return "multipleChoices"
        case 301: return "movedPermanently"
        case 302: return "found"
        case 303: return "seeOther"
        case 304: return "notModified"
        case 305: return "temporaryRedirect"
        case 306: return "permanentRedirect"

        case 400: return "badRequest"
        case 401: return "unauthorized"
        case 403: return "forbidden"
        case 404: return "notFound"
        case 405: return "methodNotAllowed"
        case 406: return "notAcceptable"
        case 407: return "proxyAuthenticationRequired"
        case 408: return "requestTimeout"
        case 409: return "conflict"
        case 410: return "gone"
        case 411: return "lengthRequired"
        case 412: return "preconditionFailed"
        case 413: return "contentTooLarge"
        case 414: return "uriTooLong"
        case 415: return "unsupportedMediaType"
        case 416: return "rangeNotSatisfiable"
        case 417: return "expectationFailed"
        case 421: return "misdirectedRequest"
        case 422: return "unprocessableContent"
        case 423: return "tooEarly"
        case 424: return "upgradeRequired"
        case 428: return "preconditionRequired"
        case 429: return "tooManyRequests"
        case 431: return "requestHeaderFieldsTooLarge"
        case 451: return "unavailableForLegalReasons"

        case 500: return "internalServerError"
        case 501: return "notImplemented"
        case 502: return "badGateway"
        case 503: return "serviceUnavailable"
        case 504: return "gatewayTimeout"
        case 505: return "httpVersionNotSupported"
        case 511: return "networkAuthenticationRequired"
        default: return nil
        }
    }
    // MARK: Parse by case name
    static func parse(_ key: String) -> HTTPResponse.Status? {
        switch key {
            case "continue": return .continue
            case "switchingProtocols": return .switchingProtocols
            case "earlyHints": return .earlyHints

            case "ok": return .ok
            case "created": return .created
            case "accepted": return .accepted
            case "nonAuthoritativeInformation": return .nonAuthoritativeInformation
            case "noContent": return .noContent
            case "resetContent": return .resetContent
            case "partialContent": return .partialContent

            case "multipleChoices": return .multipleChoices
            case "movedPermanently": return .movedPermanently
            case "found": return .found
            case "seeOther": return .seeOther
            case "notModified": return .notModified
            case "temporaryRedirect": return .temporaryRedirect
            case "permanentRedirect": return .permanentRedirect

            case "badRequest": return .badRequest
            case "unauthorized": return .unauthorized
            case "forbidden": return .forbidden
            case "notFound": return .notFound
            case "methodNotAllowed": return .methodNotAllowed
            case "notAcceptable": return .notAcceptable
            case "proxyAuthenticationRequired": return .proxyAuthenticationRequired
            case "requestTimeout": return .requestTimeout
            case "conflict": return .conflict
            case "gone": return .gone
            case "lengthRequired": return .lengthRequired
            case "preconditionFailed": return .preconditionFailed
            case "contentTooLarge": return .contentTooLarge
            case "uriTooLong": return .uriTooLong
            case "unsupportedMediaType": return .unsupportedMediaType
            case "rangeNotSatisfiable": return .rangeNotSatisfiable
            case "expectationFailed": return .expectationFailed
            case "misdirectedRequest": return .misdirectedRequest
            case "unprocessableContent": return .unprocessableContent
            case "tooEarly": return .tooEarly
            case "upgradeRequired": return .upgradeRequired
            case "preconditionRequired": return .preconditionRequired
            case "tooManyRequests": return .tooManyRequests
            case "requestHeaderFieldsTooLarge": return .requestHeaderFieldsTooLarge
            case "unavailableForLegalReasons": return .unavailableForLegalReasons

            case "internalServerError": return .internalServerError
            case "notImplemented": return .notImplemented
            case "badGateway": return .badGateway
            case "serviceUnavailable": return .serviceUnavailable
            case "gatewayTimeout": return .gatewayTimeout
            case "httpVersionNotSupported": return .httpVersionNotSupported
            case "networkAuthenticationRequired": return .networkAuthenticationRequired

            default: return nil
        }
    }
}
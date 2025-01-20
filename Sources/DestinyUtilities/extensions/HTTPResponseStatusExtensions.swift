//
//  HTTPResponseStatusExtensions.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import HTTPTypes
import SwiftSyntax

extension HTTPResponse.Status {
    // MARK: Init ExprSyntax
    public init?(expr: ExprSyntax) {
        guard let string:String = expr.memberAccess?.declName.baseName.text, let status:Self = Self.parse(string) else { return nil }
        self = status
    }
    
    // MARK: Parse by case name
    public static func parse(_ key: String) -> HTTPResponse.Status? {
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

// MARK: CustomDebugStringConvertible
extension HTTPResponse.Status : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "HTTPResponse.Status(code: \(code), reasonPhrase: \"\(reasonPhrase)\")"
    }
}
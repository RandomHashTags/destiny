//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import HTTPTypes
import Utilities

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var version:String = "HTTP/1.1"
        var middleware:[Middleware] = [], routes:[Route] = []
        for argument in node.as(MacroExpansionExprSyntax.self)!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "version":
                            version = child.expression.stringLiteral!.string
                            break
                        case "middleware":
                            middleware = parse_middleware(child.expression.array!.elements)
                            break
                        default:
                            break
                    }
                } else if let function:FunctionCallExprSyntax = child.expression.functionCall { // route
                    routes.append(parse_route(function))
                }
            }
        }
        let static_responses:String = routes.map({ "\"" + $0.method.rawValue + " /" + $0.path + "\":StaticString(\"" + $0.response(version: version, middleware: middleware) + "\")" }).joined(separator: ",")
        return "\(raw: "Router(staticResponses: [" + (static_responses.isEmpty ? ":" : static_responses) + "])")"
    }
}

// MARK: Parse Middleware
extension Router {
    static func parse_middleware(_ array: ArrayElementListSyntax) -> [Middleware] {
        var middleware:[Middleware] = []
        for element in array {
            if let function:FunctionCallExprSyntax = element.expression.functionCall {
                var appliesToMethods:Set<HTTPRequest.Method> = [], appliesToContentTypes:Set<Route.ContentType> = [], appliesHeaders:[String:String] = [:]
                for argument in function.arguments {
                    switch argument.label!.text {
                        case "appliesToMethods":
                            appliesToMethods = Set(argument.expression.array!.elements.map({ HTTPRequest.Method(rawValue: "\($0.expression.memberAccess!.declName.baseName.text)".uppercased())! }))
                            break
                        case "appliesToContentTypes":
                            appliesToContentTypes = Set(argument.expression.array!.elements.map({ Route.ContentType(rawValue: "\($0.expression.memberAccess!.declName.baseName.text)")! }))
                            break
                        case "appliesHeaders":
                            let dictionary:[(String, String)] = argument.expression.dictionary!.content.as(DictionaryElementListSyntax.self)!.map({ ($0.key.stringLiteral!.string, $0.value.stringLiteral!.string) })
                            for (key, value) in dictionary {
                                appliesHeaders[key] = value
                            }
                            break
                        default:
                            break
                    }
                }
                middleware.append(Middleware(appliesToMethods: appliesToMethods, appliesToContentTypes: appliesToContentTypes, appliesHeaders: appliesHeaders))
            }
        }
        return middleware
    }
}

// MARK: Parse Route
extension Router {
    static func parse_route(_ syntax: FunctionCallExprSyntax) -> Route {
        var method:HTTPRequest.Method = .get, path:String = ""
        var status:HTTPResponse.Status = .ok
        var contentType:Route.ContentType = .text, charset:String = "UTF-8"
        var staticResult:Route.Result? = nil
        for argument in syntax.arguments {
            let key:String = argument.label!.text
            switch key {
                case "method":
                    method = HTTPRequest.Method(rawValue: "\(argument.expression.memberAccess!.declName.baseName.text)".uppercased())!
                    break
                case "path":
                    path = argument.expression.stringLiteral!.string
                    break
                case "status":
                    status = parse_status(argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "contentType":
                    contentType = Route.ContentType(rawValue: argument.expression.memberAccess!.declName.baseName.text)!
                    break
                case "charset":
                    charset = argument.expression.stringLiteral!.string
                    break
                case "staticResult":
                    if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                        switch function.calledExpression.memberAccess!.declName.baseName.text {
                            case "string":
                                staticResult = .string(function.arguments.first!.expression.stringLiteral!.string)
                                break
                            case "bytes":
                                break
                            default:
                                break
                        }
                    }
                    break
                default:
                    break
            }
        }
        return Route(method: method, path: path, status: status, contentType: contentType, charset: charset, staticResult: staticResult, dynamicResult: nil)
    }

    static func parse_status(_ key: String) -> HTTPResponse.Status {
        switch key {
            case "continue": return .continue
            case "switchingProtocols": return.switchingProtocols
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

            default: return .internalServerError
        }
    }
}

// MARK: Misc
extension SyntaxProtocol {
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}
//
//  DynamicRoute.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import HTTPTypes
import SwiftSyntax

public struct DynamicRoute : DynamicRouteProtocol {

    public let isAsync:Bool
    public let method:HTTPRequest.Method
    public let path:String
    public let status:HTTPResponse.Status?
    public let contentType:HTTPField.ContentType
    public fileprivate(set) var defaultResponse:DynamicResponse
    public let handler:((_ request: borrowing Request, _ response: inout DynamicResponse) throws -> Void)?
    public let handlerAsync:((_ request: borrowing Request, _ response: inout DynamicResponse) async throws -> Void)?

    public fileprivate(set) var handlerLogic:String = "nil"
    public fileprivate(set) var handlerLogicAsync:String = "nil"

    public init(
        async: Bool,
        method: HTTPRequest.Method,
        path: String,
        status: HTTPResponse.Status? = nil,
        contentType: HTTPField.ContentType,
        handler: ((_ request: borrowing Request, _ response: inout DynamicResponse) throws -> Void)?,
        handlerAsync: ((_ request: borrowing Request, _ response: inout DynamicResponse) async throws -> Void)?
    ) {
        isAsync = async
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.defaultResponse = .init(status: .notImplemented, headers: [:], result: .string(""))
        self.handler = handler
        self.handlerAsync = handlerAsync
    }

    public func responder(version: String, logic: String) -> String {
        return "RouteResponses.Dynamic\(isAsync ? "Async" : "")(version: \"\(version)\", method: .\(method.caseName!), path: \"\(path)\", defaultResponse: \(defaultResponse.debugDescription), logic: \(logic))"
    }
}

public extension DynamicRoute {
    static func parse(version: String, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> DynamicRoute {
        var async:Bool = false
        var method_string:String = ".get"
        var path:String = ""
        var status:HTTPResponse.Status = .notImplemented
        var content_type:HTTPField.ContentType = .txt
        var handler:String = "nil", handlerAsync:String = "nil"
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
                case "async":
                    async = argument.expression.booleanLiteral!.literal.text == "true"
                    break
                case "method":
                    method_string = argument.expression.memberAccess!.declName.baseName.text.uppercased()
                    break
                case "path":
                    path = argument.expression.stringLiteral!.string
                    break
                case "status":
                    status = HTTPResponse.Status.parse(argument.expression.memberAccess!.declName.baseName.text) ?? .notImplemented
                    break
                case "contentType":
                    // TODO: fix .custom()
                    content_type = HTTPField.ContentType.init(rawValue: argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "handler":
                    handler = "\(argument.expression)"
                    break
                case "handlerAsync":
                    handlerAsync = "\(argument.expression)"
                    break
                default:
                    break
            }
        }
        let method:HTTPRequest.Method = HTTPRequest.Method(rawValue: method_string)!
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(method: method, contentType: content_type, status: status) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    status = applied_status
                }
                if let applied_content_type:HTTPField.ContentType = middleware.appliesContentType {
                    content_type = applied_content_type
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        headers[HTTPField.Name.contentType.rawName] = content_type.rawValue
        var route:DynamicRoute = DynamicRoute(async: async, method: method, path: path, status: status, contentType: content_type, handler: nil, handlerAsync: nil)
        route.defaultResponse = DynamicResponse(status: status, headers: headers, result: .string(""))
        route.handlerLogic = handler
        route.handlerLogicAsync = handlerAsync
        return route
    }
}
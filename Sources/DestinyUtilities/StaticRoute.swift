//
//  StaticRoute.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax

// MARK: StaticRoute
public struct StaticRoute : StaticRouteProtocol {
    public let method:HTTPRequest.Method
    public package(set) var path:String
    public let status:HTTPResponse.Status?
    public let contentType:HTTPField.ContentType, charset:String?
    public let result:RouteResult

    public init(
        method: HTTPRequest.Method,
        path: String,
        status: HTTPResponse.Status? = nil,
        contentType: HTTPField.ContentType,
        charset: String? = nil,
        result: RouteResult
    ) {
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.result = result
    }

    public func response(version: String, middleware: [StaticMiddlewareProtocol]) -> String {
        var response_status:HTTPResponse.Status? = status
        var headers:[String:String] = [:]
        headers[HTTPField.Name.contentType.rawName] = contentType.rawValue + (charset != nil ? "; charset=" + charset! : "")
        for middleware in middleware {
            if middleware.appliesToMethods.contains(method) && middleware.appliesToContentTypes.contains(contentType)
                    && (response_status != nil ? middleware.appliesToStatuses.contains(response_status!) : true) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applied_status
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        let result_string:String
        switch result {
            case .string(let string):
                result_string = string
                break
            case .bytes(let bytes):
                result_string = bytes.map({ "\($0)" }).joined()
                break
            case .json(let encodable):
                do {
                    let data:Data = try JSONEncoder().encode(encodable)
                    result_string = String(data: data, encoding: .utf8) ?? "{\"error\":400\",\"reason\":\"couldn't convert JSON encoded Data to UTF-8 String\"}"
                } catch {
                    result_string = "{\"error\":400,\"reason\":\"\(error)\"}"
                }
                break
        }
        var string:String = version + " \(response_status ?? HTTPResponse.Status.notImplemented)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        let content_length:Int = result_string.count - result_string.ranges(of: "\\").count
        string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
        return string + "\\r\\n\\r\\n" + result_string
    }
}

public extension StaticRoute {
    static func parse(_ syntax: FunctionCallExprSyntax) -> StaticRoute {
        var method:HTTPRequest.Method = .get, path:String = ""
        var status:HTTPResponse.Status? = nil
        var contentType:HTTPField.ContentType = .txt, charset:String? = nil
        var result:RouteResult = .string("")
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
                    status = HTTPResponse.Status.parse(argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "contentType":
                    contentType = HTTPField.ContentType(rawValue: argument.expression.memberAccess!.declName.baseName.text)
                    break
                case "charset":
                    charset = argument.expression.stringLiteral!.string
                    break
                case "result":
                    if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                        switch function.calledExpression.memberAccess!.declName.baseName.text {
                            case "string":
                                result = .string(function.arguments.first!.expression.stringLiteral!.string)
                                break
                            case "json":
                                break
                            case "bytes":
                                result = .bytes(function.arguments.first!.expression.array!.elements.map({ UInt8($0.expression.as(IntegerLiteralExprSyntax.self)!.literal.text)! }))
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
        return StaticRoute(method: method, path: path, status: status, contentType: contentType, charset: charset, result: result)
    }
}
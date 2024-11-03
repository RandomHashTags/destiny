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
    public package(set) var path:[String]
    public let status:HTTPResponse.Status?
    public let contentType:HTTPField.ContentType
    public let charset:String?
    public let result:RouteResult

    public init(
        method: HTTPRequest.Method,
        path: [String],
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

    public func response(version: String, middleware: [StaticMiddlewareProtocol]) throws -> String {
        let result_string:String = try result.string()
        var response_status:HTTPResponse.Status = status ?? .notImplemented
        var content_type:HTTPField.ContentType = contentType
        var headers:[String:String] = [:]
        
        for middleware in middleware {
            if middleware.handles(method: method, contentType: content_type, status: response_status) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applied_status
                }
                if let applies_content_type:HTTPField.ContentType = middleware.appliesContentType {
                    content_type = applies_content_type
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        headers[HTTPField.Name.contentType.rawName] = content_type.rawValue + (charset != nil ? "; charset=" + charset! : "")
        var string:String = version + " \(response_status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        let content_length:Int = result_string.count - result_string.ranges(of: "\\").count
        string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
        return string + "\\r\\n\\r\\n" + result_string
    }
}

public extension StaticRoute {
    static func parse(_ function: FunctionCallExprSyntax) -> StaticRoute {
        var method:HTTPRequest.Method = .get
        var path:[String] = []
        var status:HTTPResponse.Status? = nil
        var contentType:HTTPField.ContentType = .txt, charset:String? = nil
        var result:RouteResult = .string("")
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
                case "method":
                    method = HTTPRequest.Method(rawValue: "\(argument.expression.memberAccess!.declName.baseName.text)".uppercased())!
                    break
                case "path":
                    path = argument.expression.array!.elements.map({ $0.expression.stringLiteral!.string })
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
                            case "error":
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
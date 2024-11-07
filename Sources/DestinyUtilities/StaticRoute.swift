//
//  StaticRoute.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import Foundation
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// The default Static Route that powers Destiny's static routing where a complete HTTP Response is computed at compile time.
public struct StaticRoute : StaticRouteProtocol {
    public let returnType:RouteReturnType
    public let method:HTTPRequest.Method
    public let path:[String]
    public var status:HTTPResponse.Status?
    public var contentType:HTTPMediaType
    public let charset:String?
    public let result:RouteResult

    public init(
        returnType: RouteReturnType = .staticString,
        method: HTTPRequest.Method,
        path: [String],
        status: HTTPResponse.Status? = nil,
        contentType: HTTPMediaType,
        charset: String? = nil,
        result: RouteResult
    ) {
        self.returnType = returnType
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
        var content_type:HTTPMediaType = contentType
        var headers:[String:String] = [:]
        
        for middleware in middleware {
            if middleware.handles(method: method, contentType: content_type, status: response_status) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applied_status
                }
                if let applies_content_type:HTTPMediaType = middleware.appliesContentType {
                    content_type = applies_content_type
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        headers[HTTPField.Name.contentType.rawName] = nil
        headers[HTTPField.Name.contentLength.rawName] = nil
        var string:String = version + " \(response_status)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        let content_length:Int = result_string.count - result_string.ranges(of: "\\").count
        string += HTTPField.Name.contentType.rawName + ": " + content_type.rawValue + (charset != nil ? "; charset=" + charset! : "") + "\\r\\n"
        string += HTTPField.Name.contentLength.rawName + ": \(content_length)"
        return string + "\\r\\n\\r\\n" + result_string
    }

    public func responder(version: String, middleware: [any StaticMiddlewareProtocol]) throws -> StaticRouteResponseProtocol? {
        return try RouteResponses.String(returnType.encode(response(version: version, middleware: middleware)))
    }
}

public extension StaticRoute {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self? {
        var returnType:RouteReturnType = .staticString
        var method:HTTPRequest.Method = .get
        var path:[String] = []
        var status:HTTPResponse.Status? = nil
        var contentType:HTTPMediaType = HTTPMediaType.Text.plain, charset:String? = nil
        var result:RouteResult = .string("")
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
                case "returnType":
                    if let rawValue:String = argument.expression.memberAccess?.declName.baseName.text {
                        returnType = RouteReturnType(rawValue: rawValue) ?? .staticString
                    }
                    break
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
                    if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                        contentType = HTTPMediaType.parse(member) ?? HTTPMediaType(rawValue: member, caseName: member, debugDescription: member)
                    } else {
                        contentType = HTTPMediaType(rawValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string, caseName: "", debugDescription: "")
                    }
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
        return StaticRoute(returnType: returnType, method: method, path: path, status: status, contentType: contentType, charset: charset, result: result)
    }
}
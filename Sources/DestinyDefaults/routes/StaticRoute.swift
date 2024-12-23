//
//  StaticRoute.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftCompression
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// The default Static Route that powers Destiny's static routing where a complete HTTP Response is computed at compile time.
public struct StaticRoute : StaticRouteProtocol {
    public let version:HTTPVersion
    public let returnType:RouteReturnType
    public let method:HTTPRequest.Method
    public private(set) var path:[String]
    public let status:HTTPResponse.Status
    public let contentType:HTTPMediaType
    public let charset:String?
    public let result:RouteResult
    public var supportedCompressionTechniques:Set<CompressionTechnique>

    public init(
        version: HTTPVersion = .v1_0,
        returnType: RouteReturnType = .staticString,
        method: HTTPRequest.Method,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: HTTPMediaType,
        charset: String? = nil,
        result: RouteResult,
        supportedCompressionTechniques: Set<CompressionTechnique> = []
    ) {
        self.version = version
        self.returnType = returnType
        self.method = method
        self.path = path.map({ $0.description })
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.result = result
        self.supportedCompressionTechniques = supportedCompressionTechniques
    }

    public func response(middleware: [StaticMiddlewareProtocol]) -> CompleteHTTPResponse {
        var version:HTTPVersion = version
        var response_status:HTTPResponse.Status = status
        var content_type:HTTPMediaType = contentType
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: content_type, status: response_status) {
                if let applies_version:HTTPVersion = middleware.appliesVersion {
                    version = applies_version
                }
                if let applies_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applies_status
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
        return CompleteHTTPResponse(version: version, status: response_status, headers: headers, result: result, contentType: content_type, charset: charset)
    }

    @inlinable
    public func responder(middleware: [any StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol? {
        let result:String = try returnType.encode(response(middleware: middleware).string())
        return RouteResponses.String(result)
    }
}

// MARK: Parse
public extension StaticRoute {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var returnType:RouteReturnType = .staticString
        var method:HTTPRequest.Method = .get
        var path:[String] = []
        var status:HTTPResponse.Status = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaType.Text.plain, charset:String? = nil
        var result:RouteResult = .string("")
        var supportedCompressionTechniques:Set<CompressionTechnique> = []
        for argument in function.arguments {
            switch argument.label!.text {
            case "version":
                version = HTTPVersion.parse(argument.expression) ?? version
            case "returnType":
                if let rawValue:String = argument.expression.memberAccess?.declName.baseName.text {
                    returnType = RouteReturnType(rawValue: rawValue) ?? .staticString
                }
            case "method":
                method = HTTPRequest.Method(expr: argument.expression) ?? method
            case "path":
                path = argument.expression.array!.elements.map({ $0.expression.stringLiteral!.string })
            case "status":
                status = HTTPResponse.Status(expr: argument.expression) ?? .notImplemented
            case "contentType":
                if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                    contentType = HTTPMediaType.parse(member) ?? HTTPMediaType(rawValue: member, caseName: member, debugDescription: member)
                } else {
                    contentType = HTTPMediaType(rawValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string, caseName: "", debugDescription: "")
                }
            case "charset":
                charset = argument.expression.stringLiteral!.string
            case "result":
                if let function:FunctionCallExprSyntax = argument.expression.functionCall {
                    switch function.calledExpression.memberAccess!.declName.baseName.text {
                    case "string": result = .string(function.arguments.first!.expression.stringLiteral!.string)
                    case "json":   break
                    case "bytes":  result = .bytes(function.arguments.first!.expression.array!.elements.map({ UInt8($0.expression.as(IntegerLiteralExprSyntax.self)!.literal.text)! }))
                    case "error":  break
                    default:       break
                    }
                }
            case "supportedCompressionTechniques":
                supportedCompressionTechniques = Set(argument.expression.array!.elements.compactMap({ CompressionTechnique($0.expression) }))
            default:
                break
            }
        }
        var route:StaticRoute = StaticRoute(
            version: version,
            returnType: returnType,
            method: method,
            path: [],
            status: status,
            contentType: contentType,
            charset: charset,
            result: result,
            supportedCompressionTechniques: supportedCompressionTechniques
        )
        route.path = path
        return route
    }
}
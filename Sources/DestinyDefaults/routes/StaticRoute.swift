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
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// The default Static Route where a complete HTTP Response is computed at compile time.
public struct StaticRoute : StaticRouteProtocol {
    public let version:HTTPVersion
    public let returnType:RouteReturnType
    public let method:HTTPRequest.Method
    public var path:[String]
    public let status:HTTPResponse.Status
    public let contentType:HTTPMediaType
    public let charset:String?
    public let result:RouteResult
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>

    public init(
        version: HTTPVersion = .v1_0,
        returnType: RouteReturnType = .staticString,
        method: HTTPRequest.Method,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: HTTPMediaType,
        charset: String? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) {
        self.version = version
        self.returnType = returnType
        self.method = method
        self.path = path.map({ $0.description })
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.result = result
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
    }

    public var debugDescription : String {
        return """
        StaticRoute(
            version: \(version),
            returnType: .\(returnType.rawValue),
            method: .\(method.caseName!),
            path: \(path),
            status: .\(status.caseName!),
            contentType: \(contentType.debugDescription),
            charset: \(charset ?? "nil"),
            result: \(result.debugDescription),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))]
        )
        """
    }

    public func response(middleware: [StaticMiddlewareProtocol]) -> CompleteHTTPResponse {
        var version:HTTPVersion = version
        var status:HTTPResponse.Status = status
        var content_type:HTTPMediaType = contentType
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: content_type, status: status) {
                middleware.apply(version: &version, contentType: &content_type, status: &status, headers: &headers)
            }
        }
        headers[HTTPField.Name.contentType.rawName] = nil
        headers[HTTPField.Name.contentLength.rawName] = nil
        return CompleteHTTPResponse(version: version, status: status, headers: headers, result: result, contentType: content_type, charset: charset)
    }

    @inlinable
    public func responder(middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol? {
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
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
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
                path = PathComponent.parseArray(context: context, argument.expression)
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
                    case "json":   break // TODO: fix
                    case "bytes":  result = .bytes(function.arguments.first!.expression.array!.elements.map({ UInt8($0.expression.integerLiteral!.literal.text)! }))
                    case "error":  break // TODO: fix
                    default:       break
                    }
                }
            case "supportedCompressionAlgorithms":
                supportedCompressionAlgorithms = Set(argument.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
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
            supportedCompressionAlgorithms: supportedCompressionAlgorithms
        )
        route.path = path
        return route
    }
}
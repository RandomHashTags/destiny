//
//  StaticRoute.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftCompression
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute : StaticRouteProtocol {
    public let version:HTTPVersion
    public var method:HTTPRequest.Method
    public var path:[String]
    public let status:HTTPResponse.Status
    public let contentType:HTTPMediaType
    public let charset:Charset?
    public let result:RouteResult
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>

    public init<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequest.Method,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) {
        self.version = version
        self.method = method
        self.path = path.map({ $0.description })
        self.status = status
        self.contentType = contentType.structure
        self.charset = charset
        self.result = result
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
    }

    public var debugDescription : String {
        return """
        StaticRoute(
            version: .\(version),
            method: \(method.debugDescription),
            path: \(path),
            status: \(status.debugDescription),
            contentType: \(contentType.debugDescription),
            charset: \(charset?.debugDescription ?? "nil"),
            result: \(result.debugDescription),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))]
        )
        """
    }

    public func response(context: MacroExpansionContext?, function: FunctionCallExprSyntax?, middleware: [StaticMiddlewareProtocol]) -> HTTPMessage {
        var version:HTTPVersion = version
        var status:HTTPResponse.Status = status
        var contentType:HTTPMediaType = contentType
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers)
            }
        }
        if let context:MacroExpansionContext = context, let function:FunctionCallExprSyntax = function, status == .notImplemented {
            Diagnostic.routeStatusNotImplemented(context: context, node: function.calledExpression)
        }
        headers[HTTPField.Name.contentType.rawName] = nil
        headers[HTTPField.Name.contentLength.rawName] = nil
        return HTTPMessage(version: version, status: status, headers: headers, result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public func responder(context: MacroExpansionContext?, function: FunctionCallExprSyntax?, middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol? {
        let result:String = try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
        return RouteResponses.String(result)
    }
}

// MARK: Parse
public extension StaticRoute {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequest.Method = .get
        var path:[String] = []
        var status:HTTPResponse.Status = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaTypes.Text.plain.structure
        var charset:Charset? = nil
        var result:RouteResult = .string("")
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        for argument in function.arguments {
            switch argument.label!.text {
            case "version":
                version = HTTPVersion.parse(argument.expression) ?? version
            case "method":
                method = HTTPRequest.Method(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
            case "status":
                status = HTTPResponse.Status(expr: argument.expression) ?? .notImplemented
            case "contentType":
                if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                    contentType = HTTPMediaTypes.parse(member) ?? contentType
                } else {
                    contentType = HTTPMediaType(debugDescription: "", httpValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string)
                }
            case "charset":
                charset = Charset(expr: argument.expression)
            case "result":
                result = RouteResult(expr: argument.expression) ?? result
            case "supportedCompressionAlgorithms":
                supportedCompressionAlgorithms = Set(argument.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
            default:
                break
            }
        }
        var route:StaticRoute = StaticRoute(
            version: version,
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

// MARK: Convenience inits
public extension StaticRoute {
    @inlinable
    static func get<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .get, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func head<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .head, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func post<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .post, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func put<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .put, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func delete<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .delete, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func connect<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .connect, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func options<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .options, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func trace<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .trace, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    static func patch<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponse.Status = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return StaticRoute(version: version, method: .patch, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }
}
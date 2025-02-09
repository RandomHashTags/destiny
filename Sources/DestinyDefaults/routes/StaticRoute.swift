//
//  StaticRoute.swift
//
//
//  Created by Evan Anderson on 10/29/24.
//

import DestinyUtilities
import SwiftCompression
import SwiftDiagnostics

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute : StaticRouteProtocol {
    public var path:[String]
    public let contentType:HTTPMediaType
    public let result:RouteResult
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>

    public let version:HTTPVersion
    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus
    public let charset:Charset?

    public init<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
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
        var status:HTTPResponseStatus = status
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
        headers[HTTPResponseHeader.contentType.rawName] = nil
        headers[HTTPResponseHeader.contentLength.rawName] = nil
        return HTTPMessage(version: version, status: status, headers: headers, result: result, contentType: contentType, charset: charset)
    }

    @inlinable
    public func responder(context: MacroExpansionContext?, function: FunctionCallExprSyntax?, middleware: [StaticMiddlewareProtocol]) throws -> StaticRouteResponderProtocol? {
        let result:String = try response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
        return RouteResponses.String(result)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequestMethod = .get
        var path:[String] = []
        var status:HTTPResponseStatus = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaTypes.Text.plain.structure
        var charset:Charset? = nil
        var result:RouteResult = .string("")
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        for argument in function.arguments {
            switch argument.label!.text {
            case "version":
                version = HTTPVersion.parse(argument.expression) ?? version
            case "method":
                method = HTTPRequestMethod(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
            case "status":
                status = HTTPResponseStatus(expr: argument.expression) ?? .notImplemented
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
#endif

// MARK: Convenience inits
extension StaticRoute {
    @inlinable
    public static func on<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return Self(version: version, method: method, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func get<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .get, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func head<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .head, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func post<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .post, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func put<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .put, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func delete<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .delete, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func connect<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .connect, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func options<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .options, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func trace<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .trace, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }

    @inlinable
    public static func patch<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [StaticString],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        charset: Charset? = nil,
        result: RouteResult,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) -> Self {
        return on(version: version, method: .patch, path: path, status: status, contentType: contentType, charset: charset, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms)
    }
}
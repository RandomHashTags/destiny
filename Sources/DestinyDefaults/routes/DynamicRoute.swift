//
//  DynamicRoute.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import SwiftCompression
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicRoute
/// Default Dynamic Route implementation where a complete HTTP Message, computed at compile time, is modified upon requests.
public struct DynamicRoute : DynamicRouteProtocol {
    public var path:[PathComponent]
    public var contentType:HTTPMediaType
    public var defaultResponse:DynamicResponseProtocol
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
    public let handler:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    @usableFromInline package var handlerDebugDescription:String = "{ _, _ in }"

    public let version:HTTPVersion
    public var method:HTTPRequestMethod
    public var status:HTTPResponseStatus

    public init<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType.structure
        self.defaultResponse = DynamicResponse.init(version: version, status: status, headers: headers, result: result, parameters: [])
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
        self.handler = handler
    }

    @inlinable
    public func responder() -> DynamicRouteResponderProtocol {
        return DynamicRouteResponder(path: path, defaultResponse: defaultResponse, logic: handler, logicDebugDescription: handlerDebugDescription)
    }

    public var responderDebugDescription : String {
        return "DynamicRouteResponder(\npath: \(path),\ndefaultResponse: \(defaultResponse.debugDescription),\nlogic: \(handlerDebugDescription)\n)"
    }

    public var debugDescription : String {
        return """
        DynamicRoute(
            version: .\(version),
            method: \(method.debugDescription),
            path: [\(path.map({ $0.debugDescription }).joined(separator: ","))],
            status: \(status.debugDescription),
            contentType: \(contentType.debugDescription),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))],
            handler: \(handlerDebugDescription)
        )
        """
    }

    @inlinable
    public mutating func applyStaticMiddleware(_ middleware: [StaticMiddlewareProtocol]) {
        for middleware in middleware {
            if middleware.handles(version: defaultResponse.version, method: method, contentType: contentType, status: status) {
                var appliedVersion:HTTPVersion = defaultResponse.version
                middleware.apply(version: &appliedVersion, contentType: &contentType, status: &status, headers: &defaultResponse.headers)
                defaultResponse.version = appliedVersion
            }
        }
    }
}

// MARK: Parse
extension DynamicRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequestMethod = .get
        var path:[PathComponent] = []
        var status:HTTPResponseStatus = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaTypes.Text.plain.structure
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        var handler:String = "nil"
        var parameters:[String] = []
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
            case "version":
                if let parsed:HTTPVersion = HTTPVersion.parse(argument.expression) {
                    version = parsed
                }
            case "method":
                method = HTTPRequestMethod(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
                for _ in path.filter({ $0.isParameter }) {
                    parameters.append("")
                }
            case "status":
                status = HTTPResponseStatus(expr: argument.expression) ?? status
            case "contentType":
                if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                    contentType = HTTPMediaTypes.parse(member) ?? contentType
                } else {
                    contentType = HTTPMediaType(debugDescription: "", httpValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string)
                }
            case "supportedCompressionAlgorithms":
                supportedCompressionAlgorithms = Set(argument.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
            case "handler":
                handler = "\(argument.expression)"
            default:
                break
            }
        }
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers)
            }
        }
        headers[HTTPResponseHeader.contentType.rawName] = contentType.httpValue
        var route:DynamicRoute = DynamicRoute(
            version: version,
            method: method,
            path: path,
            status: status,
            contentType: contentType,
            supportedCompressionAlgorithms: supportedCompressionAlgorithms,
            handler: { _, _ in }
        )
        route.defaultResponse = DynamicResponse(version: version, status: status, headers: headers, result: .string(""), parameters: parameters)
        route.handlerDebugDescription = handler
        return route
    }
}

// MARK: Convenience inits
extension DynamicRoute {
    @inlinable
    public static func on<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return Self(version: version, method: method, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func get<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .get, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func head<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .head, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func post<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .post, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func put<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .put, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func delete<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .delete, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func connect<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .connect, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func options<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .options, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func trace<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .trace, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func patch<T: HTTPMediaTypeProtocol>(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        status: HTTPResponseStatus = .notImplemented,
        contentType: T,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) -> Self {
        return on(version: version, method: .patch, path: path, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }
}
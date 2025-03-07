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
    public typealias ConcreteRequest = Request
    public typealias ConcreteResponder = DynamicRouteResponder
    public typealias ConcreteStaticMiddleware = StaticMiddleware
    public typealias ConcreteDynamicResponse = DynamicResponse

    public var path:[PathComponent]
    public var contentType:HTTPMediaType
    public var defaultResponse:ConcreteDynamicResponse
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
    public let handler:@Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    @usableFromInline package var handlerDebugDescription:String = "{ _, _ in }"

    public let version:HTTPVersion
    public var method:HTTPRequestMethod
    public var status:HTTPResponseStatus
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [PathComponent],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        cookies: [ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPCookie] = [],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(message: HTTPMessage(version: version, status: status, headers: headers, cookies: cookies, result: result, contentType: nil, charset: nil), parameters: [])
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
        self.handler = handler
    }

    @inlinable
    public func responder() -> DynamicRouteResponder {
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
            isCaseSensitive: \(isCaseSensitive),
            status: \(status.debugDescription),
            contentType: \(contentType.debugDescription),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))],
            handler: \(handlerDebugDescription)
        )
        """
    }

    @inlinable
    public mutating func applyStaticMiddleware(_ middleware: [ConcreteStaticMiddleware]) {
        for middleware in middleware {
            if middleware.handles(version: defaultResponse.message.version, method: method, contentType: contentType, status: status) {
                var appliedVersion:HTTPVersion = defaultResponse.message.version
                var cookies = defaultResponse.message.cookies
                middleware.apply(version: &appliedVersion, contentType: &contentType, status: &status, headers: &defaultResponse.message.headers, cookies: &cookies)
                defaultResponse.message.version = appliedVersion
                defaultResponse.message.cookies = cookies
            }
        }
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension DynamicRoute {
    public static func parse(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        middleware: [ConcreteStaticMiddleware],
        _ function: FunctionCallExprSyntax
    ) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequestMethod = .get
        var path:[PathComponent] = []
        var isCaseSensitive:Bool = true
        var status:HTTPResponseStatus = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaType.textPlain
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        var handler:String = "nil"
        var parameters:[String] = []
        for argument in function.arguments {
            switch argument.label?.text {
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
            case "isCaseSensitive", "caseSensitive":
                isCaseSensitive = argument.expression.booleanIsTrue
            case "status":
                status = HTTPResponseStatus(expr: argument.expression) ?? status
            case "contentType":
                contentType = HTTPMediaType.parse(context: context, expr: argument.expression) ?? contentType
            case "supportedCompressionAlgorithms":
                supportedCompressionAlgorithms = Set(argument.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
            case "handler":
                handler = "\(argument.expression)"
            default:
                break
            }
        }
        var headers:ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init()
        var cookies:[HTTPCookie] = []
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: contentType, status: status) {
                middleware.apply(version: &version, contentType: &contentType, status: &status, headers: &headers, cookies: &cookies)
            }
        }
        var route:DynamicRoute = DynamicRoute(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status,
            contentType: contentType,
            supportedCompressionAlgorithms: supportedCompressionAlgorithms,
            handler: { _, _ in }
        )
        if !isCaseSensitive {
            route.path = path.map({ PathComponent(stringLiteral: $0.slug.lowercased()) })
        }
        route.defaultResponse = DynamicResponse(message: HTTPMessage(version: version, status: status, headers: headers, cookies: cookies, result: .string(""), contentType: contentType, charset: nil), parameters: parameters)
        route.handlerDebugDescription = handler
        return route
    }
}
#endif

// MARK: Convenience inits
extension DynamicRoute {
    @inlinable
    public static func on(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return Self(version: version, method: method, path: path, isCaseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func get(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .get, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func head(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .head, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func post(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .post, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func put(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .put, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func delete(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .delete, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func connect(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .connect, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func options(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .options, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func trace(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .trace, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }

    @inlinable
    public static func patch(
        version: HTTPVersion = .v1_0,
        path: [PathComponent],
        caseSensitive: Bool = true,
        status: HTTPResponseStatus = .notImplemented,
        contentType: HTTPMediaType,
        headers: ConcreteDynamicResponse.ConcreteHTTPMessage.ConcreteHTTPResponseHeaders = .init(),
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout ConcreteRequest, _ response: inout ConcreteDynamicResponse) async throws -> Void
    ) -> Self {
        return on(version: version, method: .patch, path: path, caseSensitive: caseSensitive, status: status, contentType: contentType, headers: headers, result: result, supportedCompressionAlgorithms: supportedCompressionAlgorithms, handler: handler)
    }
}
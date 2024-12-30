//
//  DynamicRoute.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftCompression
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicRoute
/// The default Dynamic Route where a complete HTTP Response, computed at compile time, is modified upon requests.
public struct DynamicRoute : DynamicRouteProtocol {
    public let version:HTTPVersion
    public let method:HTTPRequest.Method
    public var path:[PathComponent]
    public var status:HTTPResponse.Status
    public var contentType:HTTPMediaType
    public var defaultResponse:DynamicResponseProtocol
    public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
    public let handler:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void

    /// A string representation of the handler logic, required when parsing from the router macro.
    @usableFromInline package var handlerLogic:String = "{ _, _ in }"

    public init(
        version: HTTPVersion = .v1_0,
        method: HTTPRequest.Method,
        path: [PathComponent],
        status: HTTPResponse.Status = .notImplemented,
        contentType: HTTPMediaType,
        headers: [String:String] = [:],
        result: RouteResult = .string(""),
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = [],
        handler: @escaping @Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
    ) {
        self.version = version
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(version: .v1_1, status: .notImplemented, headers: headers, result: result, parameters: [:])
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
        self.handler = handler
    }

    @inlinable
    public func responder() -> DynamicRouteResponderProtocol {
        return DynamicRouteResponder(path: path, defaultResponse: defaultResponse, logic: handler, logicDebugDescription: handlerLogic)
    }

    public var responderDebugDescription : String {
        return "DynamicRouteResponder(\npath: \(path),\ndefaultResponse: \(defaultResponse.debugDescription),\nlogic: \(handlerLogic)\n)"
    }

    public var debugDescription: String {
        return """
        DynamicRoute(
            version: \(version),
            method: \(method.debugDescription),
            path: [\(path.map({ $0.debugDescription }).joined(separator: ","))],
            status: \(status.debugDescription),
            contentType: \(contentType.debugDescription),
            supportedCompressionAlgorithms: [\(supportedCompressionAlgorithms.map({ "." + $0.rawValue }).joined(separator: ","))],
            handler: \(handlerLogic)
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
public extension DynamicRoute {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequest.Method = .get
        var path:[PathComponent] = []
        var status:HTTPResponse.Status = .notImplemented
        var contentType:HTTPMediaType = HTTPMediaType.Text.plain
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        var handler:String = "nil"
        var parameters:[String:String] = [:]
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
            case "version":
                if let parsed:HTTPVersion = HTTPVersion.parse(argument.expression) {
                    version = parsed
                }
            case "method":
                method = HTTPRequest.Method(expr: argument.expression) ?? method
            case "path":
                path = PathComponent.parseArray(context: context, argument.expression)
                for component in path.filter({ $0.isParameter }) {
                    parameters[component.value] = ""
                }
            case "status":
                status = HTTPResponse.Status(expr: argument.expression) ?? status
            case "contentType":
                if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                    contentType = HTTPMediaType.parse(member) ?? HTTPMediaType(rawValue: member, caseName: member, debugDescription: member)
                } else {
                    contentType = HTTPMediaType(rawValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string, caseName: "", debugDescription: "")
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
        headers[HTTPField.Name.contentType.rawName] = contentType.rawValue
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
        route.handlerLogic = handler
        return route
    }
}
//
//  DynamicRoute.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: DynamicRoute
/// The default Dynamic Route that powers Destiny's dynamic routing where a complete HTTP Response, computed at compile time, is modified upon requests.
public struct DynamicRoute : DynamicRouteProtocol {
    public let isAsync:Bool
    public let version:HTTPVersion!
    public let method:HTTPRequest.Method
    public let path:[PathComponent]
    public var status:HTTPResponse.Status?
    public var contentType:HTTPMediaType
    public var defaultResponse:DynamicResponseProtocol
    public let handler:(@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) throws -> Void)?
    public let handlerAsync:(@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void)?

    /// A string representation of the synchronous handler logic, required when parsing from the router macro.
    public fileprivate(set) var handlerLogic:String = "nil"
    /// A string representation of the asynchronous handler logic, required when parsing from the router macro.
    public fileprivate(set) var handlerLogicAsync:String = "nil"

    public init(
        async: Bool,
        version: HTTPVersion? = nil,
        method: HTTPRequest.Method,
        path: [PathComponent],
        status: HTTPResponse.Status? = nil,
        contentType: HTTPMediaType,
        handler: (@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) throws -> Void)? = nil,
        handlerAsync: (@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void)? = nil
    ) {
        isAsync = async
        self.version = version
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.defaultResponse = DynamicResponse.init(version: .v1_1, status: .notImplemented, headers: [:], result: .string(""), parameters: [:])
        self.handler = handler
        self.handlerAsync = handlerAsync
    }

    public func responder(logic: String) -> String {
        return "CompiledDynamicRoute(async: \(isAsync), path: \(path), defaultResponse: \(defaultResponse.debugDescription), logic: \(isAsync ? "nil" : logic), logicAsync: \(isAsync ? logic : "nil"))"
    }

    public mutating func applyStaticMiddleware(_ middleware: [StaticMiddlewareProtocol]) {
        for middleware in middleware {
            if middleware.handles(version: defaultResponse.version, method: method, contentType: contentType, status: status!) {
                if let applied_version:HTTPVersion = middleware.appliesVersion {
                    defaultResponse.version = applied_version
                }
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    status = applied_status
                }
                if let applied_content_type:HTTPMediaType = middleware.appliesContentType {
                    contentType = applied_content_type
                }
                for (header, value) in middleware.appliesHeaders {
                    defaultResponse.headers[header] = value
                }
            }
        }
    }
}

// MARK: Parse
public extension DynamicRoute {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, middleware: [StaticMiddlewareProtocol], _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var async:Bool = false
        var method:HTTPRequest.Method = .get
        var path:[PathComponent] = []
        var status:HTTPResponse.Status = .notImplemented
        var content_type:HTTPMediaType = HTTPMediaType.Text.plain
        var handler:String = "nil", handlerAsync:String = "nil"
        var parameters:[String:String] = [:]
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
                case "async":
                    async = argument.expression.booleanLiteral!.literal.text == "true"
                case "version":
                    if let parsed:HTTPVersion = HTTPVersion.parse(argument.expression) {
                        version = parsed
                    }
                case "method":
                    method = HTTPRequest.Method(expr: argument.expression) ?? method
                case "path":
                    path = argument.expression.array!.elements.map({ PathComponent(expression: $0.expression) })
                    for component in path.filter({ $0.isParameter }) {
                        parameters[component.value] = ""
                    }
                case "status":
                    status = HTTPResponse.Status(expr: argument.expression) ?? status
                case "contentType":
                    if let member:String = argument.expression.memberAccess?.declName.baseName.text {
                        content_type = HTTPMediaType.parse(member) ?? HTTPMediaType(rawValue: member, caseName: member, debugDescription: member)
                    } else {
                        content_type = HTTPMediaType(rawValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string, caseName: "", debugDescription: "")
                    }
                    break
                case "handler":
                    handler = "\(argument.expression)"
                    break
                case "handlerAsync":
                    handlerAsync = "\(argument.expression)"
                    break
                default:
                    break
            }
        }
        var headers:[String:String] = [:]
        for middleware in middleware {
            if middleware.handles(version: version, method: method, contentType: content_type, status: status) {
                if let applied_version:HTTPVersion = middleware.appliesVersion {
                    version = applied_version
                }
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    status = applied_status
                }
                if let applied_content_type:HTTPMediaType = middleware.appliesContentType {
                    content_type = applied_content_type
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        headers[HTTPField.Name.contentType.rawName] = content_type.rawValue
        var route:DynamicRoute = DynamicRoute(async: async, version: version, method: method, path: path, status: status, contentType: content_type, handler: nil, handlerAsync: nil)
        route.defaultResponse = DynamicResponse(version: version, status: status, headers: headers, result: .string(""), parameters: parameters)
        route.handlerLogic = handler
        route.handlerLogicAsync = handlerAsync
        return route
    }
}
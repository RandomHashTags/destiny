//
//  StaticRedirectionRoute.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import DestinyUtilities
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRedirectionRoute
public struct StaticRedirectionRoute : RedirectionRouteProtocol {
    public let version:HTTPVersion!
    public let method:HTTPRequest.Method
    public let status:HTTPResponse.Status
    public package(set) var from:[String]
    public package(set) var to:[String]

    public init(
        version: HTTPVersion? = nil,
        method: HTTPRequest.Method,
        status: HTTPResponse.Status,
        from: [StaticString],
        to: [StaticString]
    ) {
        self.version = version
        self.method = method
        self.status = status
        self.from = from.map({ $0.description })
        self.to = to.map({ $0.description })
    }

    public func response() throws -> String {
        let headers:[String:String] = ["Location" : "/" + to.joined(separator: "/")]
        return DestinyDefaults.httpResponse(version: version, status: status, headers: headers, result: nil, contentType: nil, charset: nil)
    }
}

// MARK: Parse
public extension StaticRedirectionRoute {
    static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequest.Method = .get
        var from:[String] = []
        var to:[String] = []
        var status:HTTPResponse.Status = .movedPermanently
        for argument in function.arguments {
            let key:String = argument.label!.text
            switch key {
                case "version": version = HTTPVersion.parse(argument.expression) ?? version
                case "method": method = HTTPRequest.Method(expr: argument.expression) ?? method
                case "status": status = HTTPResponse.Status(expr: argument.expression) ?? status
                case "from": from = argument.expression.array!.elements.map({ $0.expression.stringLiteral!.string })
                case "to": to = argument.expression.array!.elements.map({ $0.expression.stringLiteral!.string })
                default: break
            }
        }
        var route:Self = Self(version: version, method: method, status: status, from: [], to: [])
        route.from = from
        route.to = to
        return route
    }
}
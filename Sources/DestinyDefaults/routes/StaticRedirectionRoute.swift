//
//  StaticRedirectionRoute.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import DestinyUtilities

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

// MARK: StaticRedirectionRoute
/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute : RedirectionRouteProtocol {
    public package(set) var from:[String]
    public package(set) var to:[String]
    public let version:HTTPVersion
    public let method:HTTPRequestMethod
    public let status:HTTPResponseStatus

    public init(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        status: HTTPResponseStatus,
        from: [StaticString],
        to: [StaticString]
    ) {
        self.version = version
        self.method = method
        self.status = status
        self.from = from.map({ $0.description })
        self.to = to.map({ $0.description })
    }

    public var debugDescription : String {
        return "StaticRedirectionRoute(version: .\(version), method: \(method.debugDescription), status: \(status.debugDescription), from: \(from), to: \(to))"
    }

    public func response() throws -> String {
        let headers:[String:String] = ["Location" : "/" + to.joined(separator: "/")]
        return DestinyDefaults.httpResponse(escapeLineBreak: true, version: version, status: status, headers: headers, result: nil, contentType: nil, charset: nil)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticRedirectionRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version:HTTPVersion = version
        var method:HTTPRequestMethod = .get
        var from:[String] = []
        var to:[String] = []
        var status:HTTPResponseStatus = .movedPermanently
        for argument in function.arguments {
            switch argument.label!.text {
            case "version": version = HTTPVersion.parse(argument.expression) ?? version
            case "method": method = HTTPRequestMethod(expr: argument.expression) ?? method
            case "status": status = HTTPResponseStatus(expr: argument.expression) ?? status
            case "from": from = PathComponent.parseArray(context: context, argument.expression)
            case "to": to = PathComponent.parseArray(context: context, argument.expression)
            default: break
            }
        }
        var route:Self = Self(version: version, method: method, status: status, from: [], to: [])
        route.from = from
        route.to = to
        return route
    }
}
#endif
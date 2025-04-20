//
//  StaticRedirectionRoute.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

import DestinyBlueprint
import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRedirectionRoute
/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute : RedirectionRouteProtocol {
    public package(set) var from:[String]
    public package(set) var to:[String]
    public let version:HTTPVersion
    public let method:HTTPRequestMethod
    public let status:HTTPResponseStatus
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_0,
        method: HTTPRequestMethod,
        status: HTTPResponseStatus,
        from: [StaticString],
        isCaseSensitive: Bool = true,
        to: [StaticString]
    ) {
        self.version = version
        self.method = method
        self.status = status
        self.from = from.map({ $0.description })
        self.isCaseSensitive = isCaseSensitive
        self.to = to.map({ $0.description })
    }

    public var debugDescription : String {
        "StaticRedirectionRoute(version: .\(version), method: \(method.debugDescription), status: \(status.debugDescription), from: \(from), isCaseSensitive: \(isCaseSensitive), to: \(to))"
    }

    public func response() throws -> String {
        let headers:[String:String] = ["Location" : "/" + to.joined(separator: "/")]
        return HTTPMessage.create(escapeLineBreak: true, version: version, status: status, headers: headers, result: nil, contentType: nil, charset: nil)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension StaticRedirectionRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version = version
        var method = HTTPRequestMethod.get
        var from:[String] = []
        var isCaseSensitive = true
        var to:[String] = []
        var status = HTTPResponseStatus.movedPermanently
        for argument in function.arguments {
            switch argument.label?.text {
            case "version": version = HTTPVersion.parse(argument.expression) ?? version
            case "method": method = HTTPRequestMethod(expr: argument.expression) ?? method
            case "status": status = HTTPResponseStatus(expr: argument.expression) ?? status
            case "from": from = PathComponent.parseArray(context: context, argument.expression)
            case "isCaseSensitive", "caseSensitive": isCaseSensitive = argument.expression.booleanIsTrue
            case "to": to = PathComponent.parseArray(context: context, argument.expression)
            default: break
            }
        }
        var route = Self(version: version, method: method, status: status, from: [], isCaseSensitive: isCaseSensitive, to: [])
        route.from = from
        route.to = to
        return route
    }
}
#endif

import DestinyBlueprint

// MARK: StaticRedirectionRoute
/// Default Redirection Route implementation that handles redirects for static routes.
public struct StaticRedirectionRoute: RedirectionRouteProtocol {
    public package(set) var from:[String]
    public package(set) var to:[String]
    public let version:HTTPVersion
    public let method:any HTTPRequestMethodProtocol
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool

    public init(
        version: HTTPVersion = .v1_1,
        method: any HTTPRequestMethodProtocol,
        status: HTTPResponseStatus.Code,
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

    public var debugDescription: String {
        """
        StaticRedirectionRoute(
            version: .\(version),
            method: \(method.debugDescription),
            status: \(status),
            from: \(from),
            isCaseSensitive: \(isCaseSensitive),
            to: \(to)
        )
        """
    }

    public func response() throws -> String {
        let headers:[String:String] = ["Location": "/" + to.joined(separator: "/")]
        return HTTPResponseMessage.create(escapeLineBreak: true, version: version, status: status, headers: headers, body: nil, contentType: nil, charset: nil)
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension StaticRedirectionRoute {
    public static func parse(context: some MacroExpansionContext, version: HTTPVersion, _ function: FunctionCallExprSyntax) -> Self? {
        var version = version
        var method:any HTTPRequestMethodProtocol = HTTPRequestMethod.get
        var from = [String]()
        var isCaseSensitive = true
        var to = [String]()
        var status = HTTPResponseStatus.movedPermanently.code
        for argument in function.arguments {
            switch argument.label?.text {
            case "version": version = HTTPVersion.parse(argument.expression) ?? version
            case "method": method = HTTPRequestMethod.parse(expr: argument.expression) ?? method
            case "status": status = HTTPResponseStatus.parse(expr: argument.expression)?.code ?? status
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
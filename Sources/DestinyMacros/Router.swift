//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftDiagnostics
//import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacros

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var returnType:RouterReturnType = .staticString
        var version:String = "HTTP/1.1"
        var static_middleware:[StaticMiddlewareProtocol] = []
        var dynamic_middleware:[DynamicMiddlewareProtocol] = []
        var static_routes:[(StaticRouteProtocol, FunctionCallExprSyntax)] = []
        var dynamic_routes:[DynamicRouteProtocol] = []
        for argument in node.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "returnType":
                            if let rawValue:String = child.expression.memberAccess?.declName.baseName.text {
                                returnType = RouterReturnType(rawValue: rawValue) ?? .staticString
                            }
                            break
                        case "version":
                            version = child.expression.stringLiteral!.string
                            break
                        case "middleware":
                            for element in child.expression.array!.elements {
                                //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                                if let function:FunctionCallExprSyntax = element.expression.functionCall {
                                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                                        dynamic_middleware.append(DynamicMiddleware.parse(function))
                                    } else {
                                        static_middleware.append(StaticMiddleware.parse(function))
                                    }
                                } else if let macro_expansion:MacroExpansionExprSyntax = element.expression.macroExpansion {
                                    // TODO: support custom middleware
                                } else {
                                }
                            }
                            break
                        default:
                            break
                    }
                } else if let function:FunctionCallExprSyntax = child.expression.functionCall { // route
                    //print("Router;expansion;route;function=\(function)")
                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                        dynamic_routes.append(DynamicRoute.parse(version: version, middleware: static_middleware, function))
                    } else {
                        static_routes.append((StaticRoute.parse(function), function))
                    }
                } else {
                    // TODO: support custom routes
                }
            }
        }
        let static_responses:String = parse_static_routes_string(context: context, returnType: returnType, version: version, middleware: static_middleware, static_routes)
        let dynamic_routes_string:String = parse_dynamic_routes_string(version: version, dynamic_routes)
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({ $0.description }).joined(separator: ",\n") + "\n"
        return "\(raw: "Router(\nstaticResponses: [\(static_responses)],\ndynamicResponses: [\(dynamic_routes_string)],\ndynamicMiddleware: [\(dynamic_middleware_string)]\n)")"
    }
}
// MARK: Parse static routes string
private extension Router {
    static func parse_static_routes_string(context: some MacroExpansionContext, returnType: RouterReturnType, version: String, middleware: [StaticMiddlewareProtocol], _ routes: [(StaticRouteProtocol, FunctionCallExprSyntax)]) -> String {
        return routes.isEmpty ? ":" : "\n" + routes.compactMap({ (route, function) in
            do {
                let response:String = try route.response(version: version, middleware: middleware)
                let value:String = returnType.encode(response)
                var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
                let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                return "// \(string)\n\(buffer) : " + value
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n") + "\n"
    }
}
// MARK: Parse dynamic routes string
private extension Router {
    static func parse_dynamic_routes_string(version: String, _ routes: [DynamicRouteProtocol]) -> String {
        var parameterized:[DynamicRouteProtocol] = []
        var parameterless:[DynamicRouteProtocol] = []
        for route in routes {
            if route.path.first(where: { $0[$0.startIndex] == ":" }) != nil {
                parameterized.append(route)
            } else {
                parameterless.append(route)
            }
        }
        let parameterless_string:String = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route in
            var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
            let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
            let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
            let responder:String = route.responder(version: version, logic: logic)
            return "// \(string)\n\(buffer) : \(responder)"
        }).joined(separator: ",\n") + "\n"
        return parameterless_string
    }
}

// MARK: Misc
extension SyntaxProtocol {
    var macroExpansion : MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}
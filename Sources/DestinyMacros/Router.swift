//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyDefaults
import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        /*let arguments = node.macroExpansion!.arguments
        let test:Test = Router.restructure(arguments: arguments)
        print("Router;expansion;test;restructure;test=\(test)")*/
        var version:HTTPVersion = .v1_1
        var static_middleware:[StaticMiddleware] = []
        var static_redirects:[(RedirectionRouteProtocol, SyntaxProtocol)] = []
        var dynamic_middleware:[DynamicMiddlewareProtocol] = []
        var dynamic_redirects:[(RedirectionRouteProtocol, SyntaxProtocol)] = []
        var static_routes:[(StaticRoute, FunctionCallExprSyntax)] = []
        var dynamic_routes:[(DynamicRoute, FunctionCallExprSyntax)] = []
        for argument in node.as(ExprSyntax.self)!.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "version":
                            version = HTTPVersion.parse(child.expression) ?? version
                        case "redirects":
                            parse_redirects(context: context, version: version, dictionary: child.expression.dictionary!, static_redirects: &static_redirects, dynamic_redirects: &dynamic_redirects)
                        case "middleware":
                            for element in child.expression.array!.elements {
                                //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                                if let function:FunctionCallExprSyntax = element.expression.functionCall {
                                    let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text
                                    switch decl {
                                        case "DynamicMiddleware":     dynamic_middleware.append(DynamicMiddleware.parse(function))
                                        case "DynamicCORSMiddleware": dynamic_middleware.append(DynamicCORSMiddleware.parse(function))
                                        case "StaticMiddleware":      static_middleware.append(StaticMiddleware.parse(function))
                                        default: break
                                    }
                                } else if let macro_expansion:MacroExpansionExprSyntax = element.expression.macroExpansion {
                                    // TODO: support custom middleware
                                } else {
                                }
                            }
                        default:
                            break
                    }
                } else if let function:FunctionCallExprSyntax = child.expression.functionCall { // route
                    //print("Router;expansion;route;function=\(function)")
                    if let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                        switch decl {
                            case "DynamicRoute":
                                if let route:DynamicRoute = DynamicRoute.parse(context: context, version: version, middleware: static_middleware, function) {
                                    dynamic_routes.append((route, function))
                                }
                            case "StaticRoute":
                                if let route:StaticRoute = StaticRoute.parse(context: context, version: version, function) {
                                    static_routes.append((route, function))
                                }
                            case "StaticRedirectionRoute":
                                if let route:StaticRedirectionRoute = StaticRedirectionRoute.parse(context: context, version: version, function) {
                                    static_redirects.append((route, function))
                                }
                            default:
                                break
                        }
                    }
                    
                } else {
                    // TODO: support custom routes
                }
            }
        }
        var registered_paths:Set<String> = []
        let static_responses:String = parse_static_routes_string(context: context, registered_paths: &registered_paths, redirects: static_redirects, middleware: static_middleware, static_routes)
        let dynamic_routes_string:String = parse_dynamic_routes_string(context: context, registered_paths: &registered_paths, dynamic_routes)
        let static_middleware_string:String = static_middleware.isEmpty ? "" : "\n" + static_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        return "\(raw: "Router(\nstaticResponses: [\(static_responses)],\ndynamicResponses: \(dynamic_routes_string),\nstaticMiddleware: [\(static_middleware_string)],\ndynamicMiddleware: [\(dynamic_middleware_string)]\n)")"
    }
}

private extension Router {
    static func route_path_already_registered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Parse redirects
private extension Router {
    static func parse_redirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        dictionary: DictionaryExprSyntax,
        static_redirects: inout [(RedirectionRouteProtocol, SyntaxProtocol)],
        dynamic_redirects: inout [(RedirectionRouteProtocol, SyntaxProtocol)]
    ) {
        guard let dictionary:DictionaryElementListSyntax = dictionary.content.as(DictionaryElementListSyntax.self) else { return }
        for methodElement in dictionary {
            if let method:HTTPRequest.Method = HTTPRequest.Method(expr: methodElement.key), let statuses:DictionaryElementListSyntax = methodElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                for statusElement in statuses {
                    if let status:HTTPResponse.Status = HTTPResponse.Status(expr: statusElement.key), let values:DictionaryElementListSyntax = statusElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                        for valueElement in values {
                            let from:String = valueElement.key.stringLiteral!.string
                            let to:String = valueElement.value.stringLiteral!.string
                            if from.firstIndex(of: ":") == nil {
                                var route:StaticRedirectionRoute = StaticRedirectionRoute(version: version, method: method, status: status, from: [], to: [])
                                route.from = from.split(separator: "/").map({ String($0) })
                                route.to = to.split(separator: "/").map({ String($0) })
                                static_redirects.append((route, valueElement))
                            } else {
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Parse static routes string
private extension Router {
    static func parse_static_routes_string(
        context: some MacroExpansionContext,
        registered_paths: inout Set<String>,
        redirects: [(RedirectionRouteProtocol, SyntaxProtocol)],
        middleware: [StaticMiddleware],
        _ routes: [(StaticRoute, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return ":" }
        var string:String = "\n"
        if !redirects.isEmpty {
            string += redirects.compactMap({ (route, function) in
                do {
                    var string:String = route.method.rawValue + " /" + route.from.joined(separator: "/") + " " + route.version.string
                    if registered_paths.contains(string) {
                        route_path_already_registered(context: context, node: function, string)
                        return nil
                    } else {
                        registered_paths.insert(string)
                        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                        let response:String = try route.response()
                        let value:String = RouteReturnType.staticString.encode(response)
                        return "// \(string)\n\(buffer) : " + value
                    }
                } catch {
                    return nil
                }
            }).joined(separator: ",\n") + ",\n"
        }
        string += routes.compactMap({ (route, function) in
            do {
                var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + route.version.string
                if registered_paths.contains(string) {
                    route_path_already_registered(context: context, node: function, string)
                    return nil
                } else {
                    registered_paths.insert(string)
                    let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                    let response:String = try route.response(middleware: middleware)
                    let value:String = route.returnType.encode(response)
                    return "// \(string)\n\(buffer) : " + value
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n")
        return string + "\n"
    }
}
// MARK: Parse dynamic routes string
private extension Router {
    static func parse_dynamic_routes_string(
        context: some MacroExpansionContext,
        registered_paths: inout Set<String>,
        _ routes: [(DynamicRoute, FunctionCallExprSyntax)]
    ) -> String {
        var parameterized:[(DynamicRoute, FunctionCallExprSyntax)] = []
        var parameterless:[(DynamicRoute, FunctionCallExprSyntax)] = []
        for route in routes {
            if route.0.path.first(where: { $0.isParameter }) != nil {
                parameterized.append(route)
            } else {
                parameterless.append(route)
            }
        }
        let parameterless_string:String = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route, function in
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + route.version.string
            if registered_paths.contains(string) {
                route_path_already_registered(context: context, node: function, string)
                return nil
            } else {
                registered_paths.insert(string)
                let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
                let responder:String = route.responder(logic: logic)
                return "// \(string)\n\(buffer) : \(responder)"
            }
        }).joined(separator: ",\n") + "\n"
        var parameterized_by_path_count:[String] = []
        var parameterized_string:String = ""
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                if parameterized_by_path_count.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized_by_path_count.count) {
                        parameterized_by_path_count.append("")
                    }
                }
                var string:String = route.method.rawValue + " /" + route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/") + " " + route.version.string
                if !registered_paths.contains(string) {
                    registered_paths.insert(string)
                    string = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + route.version.string
                    let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
                    let responder:String = route.responder(logic: logic)
                    parameterized_by_path_count[route.path.count].append("\n// \(string)\n" + responder)
                } else {
                    route_path_already_registered(context: context, node: function, string)
                }
            }
            parameterized_string = "\n" + parameterized_by_path_count.map({ "[\($0.isEmpty ? "" : $0 + "\n")]" }).joined(separator: ",\n") + "\n"
        }
        return "DynamicResponses(\nparameterless: [\(parameterless_string)],\nparameterized: [\(parameterized_string)])"
    }
}
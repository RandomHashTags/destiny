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
import SwiftCompression
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        /*let arguments = node.macroExpansion!.arguments
        let test:Test = Router.restructure(arguments: arguments)
        print("Router;expansion;test;restructure;test=\(test)")*/
        var version:HTTPVersion = .v1_1
        var supportedCompressionTechniques:Set<CompressionTechnique> = []
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
                    case "supportedCompressionTechniques":
                        supportedCompressionTechniques = Set(child.expression.array!.elements.compactMap({ CompressionTechnique.init($0.expression) }))
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
                            } else if let _:MacroExpansionExprSyntax = element.expression.macroExpansion {
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
                            if var route:DynamicRoute = DynamicRoute.parse(context: context, version: version, middleware: static_middleware, function) {
                                route.supportedCompressionTechniques.formUnion(supportedCompressionTechniques)
                                dynamic_routes.append((route, function))
                            }
                        case "StaticRoute":
                            if var route:StaticRoute = StaticRoute.parse(context: context, version: version, function) {
                                route.supportedCompressionTechniques.formUnion(supportedCompressionTechniques)
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
        var conditionalResponders:[RoutePath:ConditionalRouteResponderProtocol] = [:]
        let static_responses:String = static_routes_string(context: context, registered_paths: &registered_paths, conditionalResponders: &conditionalResponders, redirects: static_redirects, middleware: static_middleware, static_routes)
        let dynamic_routes_string:String = dynamic_routes_string(context: context, registered_paths: &registered_paths, dynamic_routes)
        let static_middleware_string:String = static_middleware.isEmpty ? "" : "\n" + static_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"

        var conditionalRespondersString:String
        if conditionalResponders.isEmpty {
            conditionalRespondersString = ":"
        } else {
            conditionalRespondersString = ""
            for (routePath, route) in conditionalResponders {
                conditionalRespondersString += "\n\(routePath.comment)\n\(routePath.path) : \(route.debugDescription),"
            }
            conditionalRespondersString.removeLast()
            conditionalRespondersString += "\n"
        }

        var string:String = "Router(\nstaticResponses: [\(static_responses)],"
        string += "\ndynamicResponses: \(dynamic_routes_string),"
        string += "\nconditionalResponses: [\(conditionalRespondersString)],"
        string += "\nstaticMiddleware: [\(static_middleware_string)],"
        string += "\ndynamicMiddleware: [\(dynamic_middleware_string)]"
        string += "\n)"
        return "\(raw: string)"
    }
}

private extension Router {
    static func route_path_already_registered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Redirects
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

// MARK: Static routes string
private extension Router {
    static func static_routes_string(
        context: some MacroExpansionContext,
        registered_paths: inout Set<String>,
        conditionalResponders: inout [RoutePath:ConditionalRouteResponderProtocol],
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
                    let httpResponse:CompleteHTTPResponse = route.response(middleware: middleware)
                    if route.supportedCompressionTechniques.isEmpty {
                        let value:String = try route.returnType.encode(httpResponse.string())
                        return "// \(string)\n\(buffer) : " + value
                    } else {
                        conditionalRoute(context: context, conditionalResponders: &conditionalResponders, route: route, function: function, string: string, buffer: buffer, httpResponse: httpResponse)
                        return nil
                    }
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n")
        return string + "\n"
    }
}

// MARK: Conditional route
private extension Router {
    static func conditionalRoute(
        context: some MacroExpansionContext,
        conditionalResponders: inout [RoutePath:ConditionalRouteResponderProtocol],
        route: RouteProtocol,
        function: FunctionCallExprSyntax,
        string: String,
        buffer: DestinyRoutePathType,
        httpResponse: CompleteHTTPResponse
    ) {
        guard let result:RouteResult = httpResponse.result else { return }
        let body:[UInt8]
        do {
            body = try result.bytes()
        } catch {
            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the CompleteHTTPResponse bytes: \(error).")))
            return
        }
        var httpResponse:CompleteHTTPResponse = httpResponse
        var responder:ConditionalRouteResponder = ConditionalRouteResponder(isAsync: false, conditions: [], responders: [])
        responder.conditionsDescription.removeLast() // ]
        responder.respondersDescription.removeLast() // ]
        for technique in route.supportedCompressionTechniques {
            if let compressed:CompressionResult<[UInt8]> = technique.compress(data: body) {
                httpResponse.result = .bytes(compressed.data)
                httpResponse.headers[HTTPField.Name.contentEncoding.rawName] = technique.acceptEncodingName
                httpResponse.headers[HTTPField.Name.vary.rawName] = HTTPField.Name.acceptEncoding.rawName
                do {
                    let bytes:[UInt8] = try httpResponse.bytes()
                    responder.conditionsDescription += "\n{ $0.headers[HTTPField.Name.acceptEncoding.rawName]?.contains(\"" + technique.acceptEncodingName + "\") ?? false }"
                    responder.respondersDescription += "\n" + RouteResponses.UInt8Array(bytes).debugDescription
                } catch {
                    context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the CompleteHTTPResponse bytes using the " + technique.rawValue + " compression technique: \(error).")))
                }
            } else {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "compressionFailed", message: "Failed to compress route data using the " + technique.rawValue + " technique.", severity: .warning)))
            }
        }
        responder.conditionsDescription += "\n]"
        responder.respondersDescription += "\n]"
        conditionalResponders[RoutePath(comment: "// \(string)", path: buffer)] = responder
    }
}

// MARK: RoutePath
struct RoutePath : Hashable {
    let comment:String
    let path:DestinyRoutePathType
}

// MARK: Dynamic routes string
private extension Router {
    static func dynamic_routes_string(
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
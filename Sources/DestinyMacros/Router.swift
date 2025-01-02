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

// MARK: Router
enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        var version:HTTPVersion = .v1_1
        var errorResponder:String = """
            StaticErrorResponder { error in
            RouteResponses.String(HTTPMessage(
                version: HTTPVersion.v1_1, status: .ok, headers: [:], result: .string("{\\"error\\":true,\\"reason\\":\\"\\(error)\\"}"), contentType: HTTPMediaTypes.Application.json, charset: nil)
            )
        }
        """
        var dynamicNotFoundResponder:String = "nil"
        var staticNotFoundResponder:String = #"RouteResponses.StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")"#
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        var static_middleware:[StaticMiddlewareProtocol] = []
        var static_redirects:[(RedirectionRouteProtocol, SyntaxProtocol)] = []
        var dynamic_middleware:[DynamicMiddlewareProtocol] = []
        var dynamic_redirects:[(RedirectionRouteProtocol, SyntaxProtocol)] = []
        var static_routes:[(StaticRouteProtocol, FunctionCallExprSyntax)] = []
        var dynamic_routes:[(DynamicRoute, FunctionCallExprSyntax)] = []
        var routerGroups:[RouterGroupProtocol] = []
        for child in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            if let key:String = child.label?.text {
                switch key {
                case "version":
                    version = HTTPVersion.parse(child.expression) ?? version
                case "errorResponder":
                    errorResponder = "\(child.expression)"
                case "dynamicNotFoundResponder":
                    dynamicNotFoundResponder = "\(child.expression)"
                case "staticNotFoundResponder":
                    staticNotFoundResponder = "\(child.expression)"
                case "supportedCompressionAlgorithms":
                    supportedCompressionAlgorithms = Set(child.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
                case "redirects":
                    parse_redirects(context: context, version: version, dictionary: child.expression.dictionary!, static_redirects: &static_redirects, dynamic_redirects: &dynamic_redirects)
                case "middleware":
                    for element in child.expression.array!.elements {
                        //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                        if let function:FunctionCallExprSyntax = element.expression.functionCall {
                            let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text
                            switch decl {
                            case "DynamicMiddleware":     dynamic_middleware.append(DynamicMiddleware.parse(context: context, function))
                            case "DynamicCORSMiddleware": dynamic_middleware.append(DynamicCORSMiddleware.parse(context: context, function))
                            case "DynamicDateMiddleware": dynamic_middleware.append(DynamicDateMiddleware.parse(context: context, function))
                            case "StaticMiddleware":      static_middleware.append(StaticMiddleware.parse(context: context, function))
                            default: break
                            }
                        } else if let _:MacroExpansionExprSyntax = element.expression.macroExpansion {
                            // TODO: support custom middleware
                        } else {
                        }
                    }
                case "routerGroups":
                    for element in child.expression.array!.elements {
                        if let function:FunctionCallExprSyntax = element.expression.functionCall {
                            if let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                                switch decl {
                                case "RouterGroup":
                                    routerGroups.append(RouterGroup.parse(context: context, version: version, staticMiddleware: static_middleware, dynamicMiddleware: dynamic_middleware, function))
                                default:
                                    break
                                }
                            }
                        }
                    }
                default:
                    break
                }
            } else if let function:FunctionCallExprSyntax = child.expression.functionCall { // route
                //print("Router;expansion;route;function=\(function.debugDescription)")
                let decl:String?
                var targetMethod:HTTPRequest.Method? = nil
                if let member = function.calledExpression.memberAccess {
                    decl = member.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
                    targetMethod = HTTPRequest.Method.parse(member.declName.baseName.text)
                } else {
                    decl = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
                }
                if let decl:String = decl {
                    switch decl {
                    case "DynamicRoute":
                        if var route:DynamicRoute = DynamicRoute.parse(context: context, version: version, middleware: static_middleware, function) {
                            if let method:HTTPRequest.Method = targetMethod {
                                route.method = method
                            }
                            route.supportedCompressionAlgorithms.formUnion(supportedCompressionAlgorithms)
                            dynamic_routes.append((route, function))
                        }
                    case "StaticRoute":
                        if var route:StaticRoute = StaticRoute.parse(context: context, version: version, function) {
                            if let method:HTTPRequest.Method = targetMethod {
                                route.method = method
                            }
                            route.supportedCompressionAlgorithms.formUnion(supportedCompressionAlgorithms)
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
        var registered_paths:Set<String> = []
        let router_groups_string:String = router_groups_string(context: context, registered_paths: &registered_paths, groups: routerGroups)
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

        var string:String = "Router("
        string += "\nversion: \(version),"
        string += "\nerrorResponder: \(errorResponder),"
        string += "\ndynamicNotFoundResponder: \(dynamicNotFoundResponder),"
        string += "\nstaticNotFoundResponder: \(staticNotFoundResponder),"
        string += "\nstaticResponses: [\(static_responses)],"
        string += "\ndynamicResponses: \(dynamic_routes_string),"
        string += "\nconditionalResponses: [\(conditionalRespondersString)],"
        string += "\nstaticMiddleware: [\(static_middleware_string)],"
        string += "\ndynamicMiddleware: [\(dynamic_middleware_string)],"
        string += "\nrouterGroups: [\(router_groups_string)]"
        string += "\n)"
        return "\(raw: string)"
    }
}

private extension Router {
    static func route_path_already_registered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Router Groups
private extension Router {
    static func router_groups_string(
        context: some MacroExpansionContext,
        registered_paths: inout Set<String>,
        groups: [RouterGroupProtocol]
    ) -> String {
        var string:String = ""
        if !groups.isEmpty {
            string += "\n" + groups.map({ $0.debugDescription }).joined(separator: ",\n") + "\n"
        }
        return string
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
                            let from:[String] = PathComponent.parseArray(context: context, valueElement.key)
                            let to:[String] = PathComponent.parseArray(context: context, valueElement.value)
                            if from.count(where: { $0.first == ":" }) == 0 {
                                var route:StaticRedirectionRoute = StaticRedirectionRoute(version: version, method: method, status: status, from: [], to: [])
                                route.from = from
                                route.to = to
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
        middleware: [StaticMiddlewareProtocol],
        _ routes: [(StaticRouteProtocol, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return ":" }
        var string:String = "\n"
        if !redirects.isEmpty {
            string += redirects.compactMap({ (route, function) in
                do {
                    var string:String = route.method.rawValue + " /" + route.from.joined(separator: "/") + " " + route.version.string()
                    if registered_paths.contains(string) {
                        route_path_already_registered(context: context, node: function, string)
                        return nil
                    } else {
                        registered_paths.insert(string)
                        let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                        let response:String = try route.response()
                        let value:String = RouteReturnType.staticString.debugDescription(response)
                        return "// \(string)\n\(buffer) : " + value
                    }
                } catch {
                    return nil
                }
            }).joined(separator: ",\n") + ",\n"
        }
        string += routes.compactMap({ (route, function) in
            do {
                var string:String = route.startLine
                if registered_paths.contains(string) {
                    route_path_already_registered(context: context, node: function, string)
                    return nil
                } else {
                    registered_paths.insert(string)
                    let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                    let httpResponse:DestinyUtilities.HTTPMessage = route.response(context: context, function: function, middleware: middleware)
                    if route.supportedCompressionAlgorithms.isEmpty {
                        let value:String = try route.returnType.debugDescription(httpResponse.string(escapeLineBreak: true))
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
        httpResponse: DestinyUtilities.HTTPMessage
    ) {
        guard let result:RouteResult = httpResponse.result else { return }
        let body:[UInt8]
        do {
            body = try result.bytes()
        } catch {
            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPMessage bytes: \(error).")))
            return
        }
        var httpResponse:DestinyUtilities.HTTPMessage = httpResponse
        var responder:ConditionalRouteResponder = ConditionalRouteResponder(conditions: [], responders: [])
        responder.conditionsDescription.removeLast() // ]
        responder.respondersDescription.removeLast() // ]
        for algorithm in route.supportedCompressionAlgorithms {
            if let technique:any Compressor = algorithm.technique {
                do {
                    let compressed:CompressionResult<[UInt8]> = try body.compressed(using: technique)
                    httpResponse.result = .bytes(compressed.data)
                    httpResponse.headers[HTTPField.Name.contentEncoding.rawName] = algorithm.acceptEncodingName
                    httpResponse.headers[HTTPField.Name.vary.rawName] = HTTPField.Name.acceptEncoding.rawName
                    do {
                        let bytes:String = try httpResponse.string(escapeLineBreak: false)
                        responder.conditionsDescription += "\n{ $0.headers[HTTPField.Name.acceptEncoding.rawName]?.contains(\"" + algorithm.acceptEncodingName + "\") ?? false }"
                        responder.respondersDescription += "\n" + RouteResponses.String(bytes).debugDescription
                    } catch {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPMessage bytes using the " + algorithm.rawValue + " compression algorithm: \(error).")))
                    }
                } catch {
                    context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "compressionError", message: "Encountered error while compressing bytes using the " + algorithm.rawValue + " algorithm: \(error).")))
                }
            } else {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "noTechniqueForCompressionAlgorithm", message: "Failed to compress route data using the " + algorithm.rawValue + " algorithm.", severity: .warning)))
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
            if route.0.path.count(where: { $0.isParameter }) != 0 {
                parameterized.append(route)
            } else {
                parameterless.append(route)
            }
        }
        let parameterless_string:String = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route, function in
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + route.version.string()
            if registered_paths.contains(string) {
                route_path_already_registered(context: context, node: function, string)
                return nil
            } else {
                registered_paths.insert(string)
                let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                let responder:String = route.responderDebugDescription
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
                var string:String = route.method.rawValue + " /" + route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/") + " " + route.version.string()
                if !registered_paths.contains(string) {
                    registered_paths.insert(string)
                    string = route.startLine
                    let responder:String = route.responderDebugDescription
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
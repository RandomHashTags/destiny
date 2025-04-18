//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(DestinyDefaults) && canImport(DestinyUtilities) && canImport(SwiftCompression) && canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import DestinyDefaults
import DestinyUtilities
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
                version: HTTPVersion.v1_1, status: .ok, headers: [:], cookies: [], result: .string("{\\"error\\":true,\\"reason\\":\\"\\(error)\\"}"), contentType: HTTPMediaTypes.Application.json, charset: nil)
            )
        }
        """
        var dynamicNotFoundResponder:String = "nil"
        var staticNotFoundResponder:String = #"RouteResponses.StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")"#
        var storage = Storage()
        for child in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            if let key = child.label?.text {
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
                    storage.supportedCompressionAlgorithms = Set(child.expression.array!.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }))
                case "redirects":
                    parse_redirects(context: context, version: version, dictionary: child.expression.dictionary!, static_redirects: &storage.staticRedirects, dynamic_redirects: &storage.dynamicRedirects)
                case "middleware":
                    for element in child.expression.array!.elements {
                        //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                        if let function = element.expression.functionCall {
                            switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                            case "DynamicMiddleware":     storage.dynamicMiddleware.append(DynamicMiddleware.parse(context: context, function))
                            case "DynamicCORSMiddleware": storage.dynamicMiddleware.append(DynamicCORSMiddleware.parse(context: context, function))
                            case "DynamicDateMiddleware": storage.dynamicMiddleware.append(DynamicDateMiddleware.parse(context: context, function))
                            case "StaticMiddleware":      storage.staticMiddleware.append(StaticMiddleware.parse(context: context, function))
                            default: break
                            }
                        } else if let _ = element.expression.macroExpansion {
                            // TODO: support custom middleware
                        } else {
                        }
                    }
                case "routerGroups":
                    for element in child.expression.array!.elements {
                        if let function = element.expression.functionCall {
                            switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                            case "RouterGroup":
                                storage.routerGroups.append(RouterGroup.parse(context: context, version: version, staticMiddleware: storage.staticMiddleware, dynamicMiddleware: storage.dynamicMiddleware, function))
                            default:
                                break
                            }
                        }
                    }
                default:
                    break
                }
            } else if let function = child.expression.functionCall { // route
                //print("Router;expansion;route;function=\(function.debugDescription)")
                let decl:String?
                var targetMethod:HTTPRequestMethod? = nil
                if let member = function.calledExpression.memberAccess {
                    decl = member.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
                    targetMethod = HTTPRequestMethod(expr: member)
                } else {
                    decl = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
                }
                switch decl {
                case "DynamicRoute":
                    if var route = DynamicRoute.parse(context: context, version: version, middleware: storage.staticMiddleware, function) {
                        if let method = targetMethod {
                            route.method = method
                        }
                        route.supportedCompressionAlgorithms.formUnion(storage.supportedCompressionAlgorithms)
                        storage.dynamicRoutes.append((route, function))
                    }
                case "StaticRoute":
                    if var route = StaticRoute.parse(context: context, version: version, function) {
                        if let method = targetMethod {
                            route.method = method
                        }
                        route.supportedCompressionAlgorithms.formUnion(storage.supportedCompressionAlgorithms)
                        storage.staticRoutes.append((route, function))
                    }
                case "StaticRedirectionRoute":
                    if let route = StaticRedirectionRoute.parse(context: context, version: version, function) {
                        storage.staticRedirects.append((route, function))
                    }
                default:
                    break
                }
            } else {
                // TODO: support custom routes
            }
        }
        
        let routerGroupsString = storage.routerGroupsString(context: context)
        let conditionalRespondersString = storage.conditionalRespondersString()
        var string:String = "Router("
        string += "\nversion: .\(version),"
        string += "\nerrorResponder: \(errorResponder),"
        string += "\ndynamicNotFoundResponder: \(dynamicNotFoundResponder),"
        string += "\nstaticNotFoundResponder: \(staticNotFoundResponder),"

        let caseSensitiveResponders = routeResponderStorage(
            staticResponses: storage.staticResponsesString(context: context, caseSensitive: true),
            dynamicResponses: storage.dynamicResponsesString(context: context, caseSensitive: true),
            conditionalResponses: ":"
        )
        let caseInsensitiveResponders = routeResponderStorage(
            staticResponses: storage.staticResponsesString(context: context, caseSensitive: false),
            dynamicResponses: storage.dynamicResponsesString(context: context, caseSensitive: false),
            conditionalResponses: conditionalRespondersString
        )
        string += "\ncaseSensitiveResponders: " + caseSensitiveResponders + ","
        string += "\ncaseInsensitiveResponders: " + caseInsensitiveResponders + ","
        string += "\nstaticMiddleware: [\(storage.staticMiddlewareString())],"
        string += "\ndynamicMiddleware: [\(storage.dynamicMiddlewareString())],"
        string += "\nrouterGroups: [\(routerGroupsString)]"
        string += "\n)"
        return "\(raw: string)"
    }
    private static func routeResponderStorage(staticResponses: String, dynamicResponses: String, conditionalResponses: String) -> String {
        var string:String = "RouterResponderStorage("
        string += "\nstatic: [\(staticResponses)],"
        string += "\ndynamic: \(dynamicResponses),"
        string += "\nconditional: [\(conditionalResponses)]"
        string += "\n)"
        return string
    }
}

extension Router {
    static func routePathAlreadyRegistered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Storage
extension Router {
    struct Storage {
        var supportedCompressionAlgorithms:Set<CompressionAlgorithm> = []
        
        var dynamicMiddleware:[any DynamicMiddlewareProtocol] = []
        var dynamicRedirects:[(any RedirectionRouteProtocol, SyntaxProtocol)] = []
        var dynamicRoutes:[(DynamicRoute, FunctionCallExprSyntax)] = []

        var staticMiddleware:[any StaticMiddlewareProtocol] = []
        var staticRedirects:[(any RedirectionRouteProtocol, SyntaxProtocol)] = []
        var staticRoutes:[(any StaticRouteProtocol, FunctionCallExprSyntax)] = []
        
        var routerGroups:[any RouterGroupProtocol] = []

        private var conditionalResponders:[RoutePath:any ConditionalRouteResponderProtocol] = [:]
        private var registeredPaths:Set<String> = []

        mutating func routerGroupsString(context: some MacroExpansionContext) -> String {
            var string:String = ""
            if !routerGroups.isEmpty {
                string += "\n" + routerGroups.map({ $0.debugDescription }).joined(separator: ",\n") + "\n"
            }
            return string
        }

        func staticMiddlewareString() -> String {
            return staticMiddleware.isEmpty ? "" : "\n" + staticMiddleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        }
        func dynamicMiddlewareString() -> String {
            return dynamicMiddleware.isEmpty ? "" : "\n" + dynamicMiddleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        }

        mutating func staticResponsesString(context: some MacroExpansionContext, caseSensitive: Bool) -> String {
            return static_routes_string(context: context, isCaseSensitive: caseSensitive, redirects: staticRedirects.filter({ $0.0.isCaseSensitive == caseSensitive }), middleware: staticMiddleware, staticRoutes.filter({ $0.0.isCaseSensitive == caseSensitive }))
        }

        mutating func dynamicResponsesString(context: some MacroExpansionContext, caseSensitive: Bool) -> String {
            return dynamic_routes_string(context: context, isCaseSensitive: caseSensitive, dynamicRoutes.filter({ $0.0.isCaseSensitive == caseSensitive }))
        }

        func conditionalRespondersString() -> String {
            var string:String
            if conditionalResponders.isEmpty {
                string = ":"
            } else {
                string = ""
                for (routePath, route) in conditionalResponders {
                    string += "\n\(routePath.comment)\n\(routePath.path) : \(route.debugDescription),"
                }
                string.removeLast()
                string += "\n"
            }
            return string
        }
    }
}

// MARK: Redirects
extension Router {
    static func parse_redirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        dictionary: DictionaryExprSyntax,
        static_redirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)],
        dynamic_redirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)]
    ) {
        guard let dictionary = dictionary.content.as(DictionaryElementListSyntax.self) else { return }
        for methodElement in dictionary {
            if let method = HTTPRequestMethod(expr: methodElement.key), let statuses:DictionaryElementListSyntax = methodElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                for statusElement in statuses {
                    if let status = HTTPResponseStatus(expr: statusElement.key), let values:DictionaryElementListSyntax = statusElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                        for valueElement in values {
                            let from:[String] = PathComponent.parseArray(context: context, valueElement.key)
                            let to:[String] = PathComponent.parseArray(context: context, valueElement.value)
                            if from.count(where: { $0.first == ":" }) == 0 {
                                var route = StaticRedirectionRoute(version: version, method: method, status: status, from: [], to: [])
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
extension Router.Storage {
    mutating func static_routes_string(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        redirects: [(any RedirectionRouteProtocol, SyntaxProtocol)],
        middleware: [any StaticMiddlewareProtocol],
        _ routes: [(any StaticRouteProtocol, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return ":" }
        var string = "\n"
        if !redirects.isEmpty {
            string += redirects.compactMap({ (route, function) in
                do {
                    var string = route.method.rawName + " /" + route.from.joined(separator: "/") + " " + route.version.string
                    if !isCaseSensitive {
                        string = string.lowercased()
                    }
                    if registeredPaths.contains(string) {
                        Router.routePathAlreadyRegistered(context: context, node: function, string)
                        return nil
                    } else {
                        registeredPaths.insert(string)
                        let buffer = DestinyRoutePathType(&string)
                        let response = RouteResult.staticString(try route.response()).responderDebugDescription
                        return "// \(string)\n\(buffer)\n: " + response
                    }
                } catch {
                    return nil
                }
            }).joined(separator: ",\n\n") + ",\n"
        }
        string += routes.compactMap({ (route, function) in
            do {
                var string = route.startLine
                if !isCaseSensitive {
                    string = string.lowercased()
                }
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                    return nil
                } else {
                    registeredPaths.insert(string)
                    let buffer = DestinyRoutePathType(&string)
                    let httpResponse = route.response(context: context, function: function, middleware: middleware)
                    if route.supportedCompressionAlgorithms.isEmpty {
                        let value = try route.result.responderDebugDescription(httpResponse)
                        return "// \(string)\n\(buffer)\n: " + value
                    } else {
                        Router.conditionalRoute(context: context, conditionalResponders: &conditionalResponders, route: route, function: function, string: string, buffer: buffer, httpResponse: httpResponse)
                        return nil
                    }
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n\n")
        return string + "\n"
    }
}

// MARK: Conditional route
extension Router {
    static func conditionalRoute(
        context: some MacroExpansionContext,
        conditionalResponders: inout [RoutePath:any ConditionalRouteResponderProtocol],
        route: any RouteProtocol,
        function: FunctionCallExprSyntax,
        string: String,
        buffer: DestinyRoutePathType,
        httpResponse: DestinyUtilities.HTTPMessage
    ) {
        guard let result = httpResponse.result else { return }
        let body:[UInt8]
        do {
            body = try result.bytes()
        } catch {
            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPMessage bytes: \(error).")))
            return
        }
        var httpResponse = httpResponse
        var responder = ConditionalRouteResponder(conditions: [], responders: [])
        responder.conditionsDescription.removeLast() // ]
        responder.respondersDescription.removeLast() // ]
        for algorithm in route.supportedCompressionAlgorithms {
            if let technique:any Compressor = algorithm.technique {
                do {
                    let compressed = try body.compressed(using: technique)
                    httpResponse.result = .bytes(compressed.data)
                    httpResponse.headers[HTTPResponseHeader.contentEncoding.rawName] = algorithm.acceptEncodingName
                    httpResponse.headers[HTTPResponseHeader.vary.rawName] = HTTPRequestHeader.acceptEncoding.rawName
                    do {
                        let bytes:String = try httpResponse.string(escapeLineBreak: false)
                        responder.conditionsDescription += "\n{ $0.headers[HTTPRequestHeader.acceptEncoding.rawName]?.contains(\"" + algorithm.acceptEncodingName + "\") ?? false }"
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
extension Router.Storage {
    mutating func dynamic_routes_string(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        _ routes: [(DynamicRoute, FunctionCallExprSyntax)]
    ) -> String {
        var parameterized:[(DynamicRoute, FunctionCallExprSyntax)] = []
        var parameterless:[(DynamicRoute, FunctionCallExprSyntax)] = []
        var catchall:[(DynamicRoute, FunctionCallExprSyntax)] = []
        for route in routes {
            if route.0.path.count(where: { $0.isParameter }) != 0 {
                if route.0.path.count(where: { $0 == .catchall }) != 0 {
                    catchall.append(route)
                } else {
                    parameterized.append(route)
                }
            } else {
                parameterless.append(route)
            }
        }
        let parameterless_string = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route, function in
            var string = route.startLine
            if !isCaseSensitive {
                string = string.lowercased()
            }
            if registeredPaths.contains(string) {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                return nil
            } else {
                registeredPaths.insert(string)
                let buffer = DestinyRoutePathType(&string)
                let responder = route.responderDebugDescription
                return "// \(string)\n\(buffer)\n: \(responder)"
            }
        }).joined(separator: ",\n\n") + "\n"
        var parameterized_by_path_count:[String] = []
        var parameterizedString:String = ""
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                if parameterized_by_path_count.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized_by_path_count.count) {
                        parameterized_by_path_count.append("")
                    }
                }
                var string = route.method.rawName + " /" + route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/") + " " + route.version.string
                if !registeredPaths.contains(string) {
                    registeredPaths.insert(string)
                    string = route.startLine
                    if !isCaseSensitive {
                        string = string.lowercased()
                    }
                    let responder = route.responderDebugDescription
                    parameterized_by_path_count[route.path.count].append("\n// \(string)\n" + responder)
                } else {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                }
            }
            parameterizedString = "\n" + parameterized_by_path_count.map({ "[\($0.isEmpty ? "" : $0 + "\n")]" }).joined(separator: ",\n") + "\n"
        }
        let catchallString = catchall.isEmpty ? "" : "\n" + catchall.compactMap({ route, function in
            var string = route.startLine
            if !isCaseSensitive {
                string = string.lowercased()
            }
            if registeredPaths.contains(string) {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                return nil
            } else {
                registeredPaths.insert(string)
                let responder = route.responderDebugDescription
                return "// \(string)\n\(responder)"
            }
        }).joined(separator: ",\n\n") + "\n"
        return "DynamicResponses(\nparameterless: [\(parameterless_string)],\nparameterized: [\(parameterizedString)],\ncatchall: [\(catchallString)]\n)"
    }
}
#endif
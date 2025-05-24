
#if canImport(DestinyDefaults) && canImport(DestinyBlueprint) && canImport(SwiftCompression) && canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import DestinyDefaults
import DestinyBlueprint
import SwiftCompression
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: ExpressionMacro
enum Router: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        return "\(raw: compute(arguments: node.as(ExprSyntax.self)!.macroExpansion!.arguments, context: context))"
    }
    private static func routeResponderStorage(staticResponses: String, dynamicResponses: String, conditionalResponses: String) -> String {
        var string = "RouterResponderStorage("
        string += "\nstatic: \(staticResponses),"
        string += "\ndynamic: \(dynamicResponses),"
        string += "\nconditional: [\(conditionalResponses)]"
        string += "\n)"
        return string
    }
}

// MARK: DeclarationMacro
extension Router: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var mutable = false
        var typeAnnotation:String? = nil
        let arguments = node.as(ExprSyntax.self)!.macroExpansion!.arguments
        for argument in arguments.prefix(2) {
            switch argument.label?.text {
            case "mutable":
                mutable = argument.expression.booleanIsTrue
            case "typeAnnotation":
                typeAnnotation = argument.expression.stringLiteral?.string
            default:
                break
            }
        }
        let computed = compute(arguments: arguments, context: context)
        var string = (mutable ? "var" : "let") + " router"
        if let typeAnnotation {
            string += ":" + typeAnnotation
        }
        string += " = " + computed
        return [.init(stringLiteral: string)]
    }
}

// MARK: Compute
extension Router {
    static func compute(
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> String {
        var version = HTTPVersion.v1_1
        var errorResponder = """
        StaticErrorResponder { error in
            RouteResponses.String(
                HTTPMessage(
                    version: HTTPVersion.v1_1,
                    status: HTTPResponseStatus.ok.code,
                    headers: [:],
                    cookies: [],
                    result: RouteResult.string("{\\"error\\":true,\\"reason\\":\\"\\(error)\\"}"),
                    contentType: HTTPMediaType.applicationJson,
                    charset: nil
                )
            )
        }
        """
        var dynamicNotFoundResponder = "nil"
        var staticNotFoundResponder = #"RouteResponses.StaticString("HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length:9\r\n\r\nnot found")"#
        var storage = Storage()
        var isCompiled = false
        for child in arguments {
            if let key = child.label?.text {
                switch key {
                case "isCompiled":
                    isCompiled = child.expression.booleanIsTrue
                case "version":
                    version = HTTPVersion.parse(child.expression) ?? version
                case "errorResponder":
                    errorResponder = "\(child.expression)"
                case "dynamicNotFoundResponder":
                    dynamicNotFoundResponder = "\(child.expression)"
                    if dynamicNotFoundResponder == "nil" {
                        dynamicNotFoundResponder = "Optional<DynamicRouteResponder>.none"
                    }
                case "staticNotFoundResponder":
                    staticNotFoundResponder = "\(child.expression)"
                case "supportedCompressionAlgorithms":
                    if let elements = child.expression.array?.elements.compactMap({ CompressionAlgorithm.parse($0.expression) }) {
                        storage.supportedCompressionAlgorithms = Set(elements)
                    }
                case "redirects":
                    if let dictionary = child.expression.dictionary {
                        parseRedirects(context: context, version: version, dictionary: dictionary, staticRedirects: &storage.staticRedirects, dynamicRedirects: &storage.dynamicRedirects)
                    }
                case "middleware":
                    if let elements = child.expression.array?.elements {
                        for element in elements {
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
                    }
                case "routerGroups":
                    if let elements = child.expression.array?.elements {
                        for element in elements {
                            if let function = element.expression.functionCall {
                                switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                                case "RouterGroup":
                                    storage.routerGroups.append(RouterGroup.parse(context: context, version: version, staticMiddleware: storage.staticMiddleware, dynamicMiddleware: storage.dynamicMiddleware, function))
                                default:
                                    break
                                }
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
        var string = "Router("
        string += "\nversion: .\(version),"
        string += "\nerrorResponder: \(errorResponder),"
        string += "\ndynamicNotFoundResponder: \(dynamicNotFoundResponder),"
        string += "\nstaticNotFoundResponder: \(staticNotFoundResponder),"

        let caseSensitiveResponders = routeResponderStorage(
            staticResponses: storage.staticResponsesString(context: context, caseSensitive: true, isCompiled: isCompiled),
            dynamicResponses: storage.dynamicResponsesString(context: context, caseSensitive: true),
            conditionalResponses: ":"
        )
        let caseInsensitiveResponders = routeResponderStorage(
            staticResponses: storage.staticResponsesString(context: context, caseSensitive: false, isCompiled: isCompiled),
            dynamicResponses: storage.dynamicResponsesString(context: context, caseSensitive: false),
            conditionalResponses: conditionalRespondersString
        )
        string += "\ncaseSensitiveResponders: " + caseSensitiveResponders + ","
        string += "\ncaseInsensitiveResponders: " + caseInsensitiveResponders + ","
        string += "\nstaticMiddleware: [\(storage.staticMiddlewareString())],"
        string += "\ndynamicMiddleware: [\(storage.dynamicMiddlewareString())],"
        string += "\nrouterGroups: [\(routerGroupsString)]"
        string += "\n)"
        return string
    }
}

// MARK: Diagnostics
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

        var staticMiddleware:[StaticMiddleware] = []
        var staticRedirects:[(any RedirectionRouteProtocol, SyntaxProtocol)] = []
        var staticRoutes:[(StaticRoute, FunctionCallExprSyntax)] = []
        
        var routerGroups:[any RouterGroupProtocol] = []

        private var conditionalResponders:[RoutePath:any ConditionalRouteResponderProtocol] = [:]
        private var registeredPaths:Set<String> = []

        mutating func routerGroupsString(context: some MacroExpansionContext) -> String {
            var string = ""
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

        mutating func staticResponsesString(context: some MacroExpansionContext, caseSensitive: Bool, isCompiled: Bool) -> String {
            return staticRoutesString(
                context: context,
                isCaseSensitive: caseSensitive,
                isCompiled: isCompiled,
                redirects: staticRedirects.filter({ $0.0.isCaseSensitive == caseSensitive }),
                middleware: staticMiddleware,
                staticRoutes.filter({ $0.0.isCaseSensitive == caseSensitive })
            )
        }

        mutating func dynamicResponsesString(context: some MacroExpansionContext, caseSensitive: Bool) -> String {
            return dynamicRoutesString(context: context, isCaseSensitive: caseSensitive, dynamicRoutes.filter({ $0.0.isCaseSensitive == caseSensitive }))
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
    static func parseRedirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        dictionary: DictionaryExprSyntax,
        staticRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)],
        dynamicRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)]
    ) {
        guard let dictionary = dictionary.content.as(DictionaryElementListSyntax.self) else { return }
        for methodElement in dictionary {
            if let method = HTTPRequestMethod(expr: methodElement.key), let statuses = methodElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                for statusElement in statuses {
                    if let status = HTTPResponseStatus.parse(expr: statusElement.key)?.code, let values = statusElement.value.dictionary?.content.as(DictionaryElementListSyntax.self) {
                        for valueElement in values {
                            let from:[String] = PathComponent.parseArray(context: context, valueElement.key)
                            let to:[String] = PathComponent.parseArray(context: context, valueElement.value)
                            if from.firstIndex(where: { $0.first == ":" }) == nil {
                                var route = StaticRedirectionRoute(version: version, method: method, status: status, from: [], to: [])
                                route.from = from
                                route.to = to
                                staticRedirects.append((route, valueElement))
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
    struct Route {
        let path:String
        let buffer:DestinyRoutePathType
        let responder:String
    }
    mutating func staticRoutesString(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        isCompiled: Bool,
        redirects: [(any RedirectionRouteProtocol, SyntaxProtocol)],
        middleware: [StaticMiddleware],
        _ routes: [(StaticRoute, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return ".init()" }
        var staticStrings = [String]()
        var strings = [String]()
        var stringsWithDateHeader = [String]()
        var uint8Arrays = [String]()
        var uint16Arrays = [String]()
        let separator:String
        let getResponderValue:(Router.Storage.Route) -> String
        let responderStoragePrefix:String
        if isCompiled {
            separator = ""
            getResponderValue = {
                return "// \($0.path)\n.init(\npath: \($0.buffer),\nresponder: " + $0.responder + "\n)"
            }
            responderStoragePrefix = "Compiled"
        } else {
            separator = ":"
            getResponderValue = {
                return "// \($0.path)\n\($0.buffer)\n: " + $0.responder
            }
            responderStoragePrefix = ""
        }
        if !redirects.isEmpty {
            for (route, function) in redirects {
                do {
                    var string = route.method.rawName.string() + " /" + route.from.joined(separator: "/") + " " + route.version.string
                    if !isCaseSensitive {
                        string = string.lowercased()
                    }
                    if registeredPaths.contains(string) {
                        Router.routePathAlreadyRegistered(context: context, node: function, string)
                    } else {
                        registeredPaths.insert(string)
                        let buffer = DestinyRoutePathType(&string)
                        let responder = try RouteResult.stringWithDateHeader(route.response()).responderDebugDescription
                        stringsWithDateHeader.append(getResponderValue(.init(path: string, buffer: buffer, responder: responder)))
                    }
                } catch {
                }
            }
        }
        for (route, function) in routes {
            do {
                var string = route.startLine
                if !isCaseSensitive {
                    string = string.lowercased()
                }
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                } else {
                    registeredPaths.insert(string)
                    let buffer = DestinyRoutePathType(&string)
                    let httpResponse = route.response(context: context, function: function, middleware: middleware)
                    if route.supportedCompressionAlgorithms.isEmpty {
                        if let responder = try route.result?.responderDebugDescription(httpResponse) {
                            let value = getResponderValue(.init(path: string, buffer: buffer, responder: responder))
                            switch responder.split(separator: "(").first {
                            case "RouteResponses.StaticString": staticStrings.append(value)
                            case "RouteResponses.String": strings.append(value)
                            case "RouteResponses.StringWithDateHeader": stringsWithDateHeader.append(value)
                            case "RouteResponses.UInt8Array": uint8Arrays.append(value)
                            case "RouteResponses.UInt16Array": uint16Arrays.append(value)
                            default: break
                            }
                        }
                    } else {
                        Router.conditionalRoute(
                            context: context,
                            conditionalResponders: &conditionalResponders,
                            route: route,
                            function: function,
                            string: string,
                            buffer: buffer,
                            httpResponse: httpResponse as! DestinyDefaults.HTTPMessage // TODO: fix
                        )
                    }
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
            }
        }
        var values = [String]()
        values.append("staticStrings: ["         + respondersToString(staticStrings, separator) + "]")
        values.append("strings: ["               + respondersToString(strings, separator) + "]")
        values.append("stringsWithDateHeader: [" + respondersToString(stringsWithDateHeader, separator) + "]")
        values.append("uint8Arrays: ["           + respondersToString(uint8Arrays, separator) + "]")
        values.append("uint16Arrays: ["          + respondersToString(uint16Arrays, separator) + "]")
        return responderStoragePrefix + "StaticResponderStorage(" + (values.isEmpty ? "" : "\n" + values.joined(separator: ",\n") + "\n") + ")"
    }
    private func respondersToString(_ values: [String], _ separator: String) -> String {
        return values.isEmpty ? separator : "\n" + values.joined(separator: ",\n") + "\n"
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
        httpResponse: DestinyDefaults.HTTPMessage
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
        var responder = ConditionalRouteResponder(staticConditions: [], staticResponders: [], dynamicConditions: [], dynamicResponders: [])
        responder.staticConditionsDescription.removeLast() // ]
        responder.staticRespondersDescription.removeLast() // ]
        //responder.dynamicConditionsDescription.removeLast() // ] // TODO: support
        //responder.dynamicRespondersDescription.removeLast() // ]
        for algorithm in route.supportedCompressionAlgorithms {
            if let technique = algorithm.technique {
                do {
                    let compressed = try body.compressed(using: technique)
                    httpResponse.result = RouteResult.bytes(compressed.data)
                    httpResponse.setHeader(key: HTTPResponseHeader.contentEncoding.rawNameString, value: algorithm.acceptEncodingName)
                    httpResponse.setHeader(key: HTTPResponseHeader.vary.rawNameString, value: HTTPRequestHeader.acceptEncoding.rawNameString)
                    do {
                        let bytes = try httpResponse.string(escapeLineBreak: false)
                        responder.staticConditionsDescription += "\n{ $0.headers[HTTPRequestHeader.acceptEncoding.rawNameString]?.contains(\"" + algorithm.acceptEncodingName + "\") ?? false }"
                        responder.staticRespondersDescription += "\n" + RouteResponses.String(bytes).debugDescription
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
        responder.staticConditionsDescription += "\n]"
        responder.staticRespondersDescription += "\n]"
        conditionalResponders[RoutePath(comment: "// \(string)", path: buffer)] = responder
    }
}

// MARK: RoutePath
struct RoutePath: Hashable {
    let comment:String
    let path:DestinyRoutePathType
}

// MARK: Dynamic routes string
extension Router.Storage {
    mutating func dynamicRoutesString(
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
        let parameterlessString = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route, function in
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
        var parameterizedByPathCount = [String]()
        var parameterizedString = ""
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                if parameterizedByPathCount.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterizedByPathCount.count) {
                        parameterizedByPathCount.append("")
                    }
                }
                var string = route.method.rawNameString + " /" + route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/") + " " + route.version.string
                if !registeredPaths.contains(string) {
                    registeredPaths.insert(string)
                    string = route.startLine
                    if !isCaseSensitive {
                        string = string.lowercased()
                    }
                    let responder = route.responderDebugDescription
                    parameterizedByPathCount[route.path.count].append("\n// \(string)\n" + responder)
                } else {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                }
            }
            parameterizedString = "\n" + parameterizedByPathCount.map({ "[\($0.isEmpty ? "" : $0 + "\n")]" }).joined(separator: ",\n") + "\n"
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
        return "DynamicResponderStorage(\nparameterless: [\(parameterlessString)],\nparameterized: [\(parameterizedString)],\ncatchall: [\(catchallString)]\n)"
    }
}
#endif

import DestinyDefaults
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: ExpressionMacro
enum Router: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        return "\(raw: compute(arguments: node.as(ExprSyntax.self)!.macroExpansion!.arguments, context: context).router)"
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
        for arg in arguments.prefix(2) {
            switch arg.label?.text {
            case "mutable":
                mutable = arg.expression.booleanIsTrue
            case "typeAnnotation":
                guard let string = arg.expression.stringLiteral?.string else {
                    context.diagnose(DiagnosticMsg.expectedStringLiteral(expr: arg.expression))
                    break
                }
                typeAnnotation = string
            default:
                break
            }
        }
        let (router, structs) = compute(arguments: arguments, context: context)
        var string = structs
        if !string.isEmpty {
            string += "\n"
        }
        string += "struct DeclaredRouter {\n"
        string += "static \(mutable ? "var" : "let") router"
        if let typeAnnotation {
            string += ":" + typeAnnotation
        }
        string += " = " + router
        string += "\n}"
        return [.init(stringLiteral: string)]
    }
}

// MARK: Compute
extension Router {
    static func compute(
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: String, structs: String) {
        var version = HTTPVersion.v1_1
        let defaultStaticErrorResponse = (try? DestinyDefaults.HTTPResponseMessage(
            version: HTTPVersion.v1_1,
            status: HTTPStandardResponseStatus.ok.code,
            headers: [:],
            cookies: [],
            body: "{\"error\":true,\"reason\":\"\\(error)\"}",
            contentType: HTTPMediaTypeApplication.json,
            charset: nil
        ).string(escapeLineBreak: true)) ?? ""
        var errorResponder = """
        StaticErrorResponder({ error in
            \"\(defaultStaticErrorResponse)\"
        })
        """
        var dynamicNotFoundResponder = "nil"
        var staticNotFoundResponder = ""
        var storage = Storage()
        for child in arguments {
            if let label = child.label {
                let key = label.text
                switch key {
                case "version":
                    version = HTTPVersion.parse(child.expression) ?? version
                case "errorResponder":
                    errorResponder = "\(child.expression)"
                case "dynamicNotFoundResponder":
                    dynamicNotFoundResponder = "\(child.expression)"
                case "staticNotFoundResponder":
                    staticNotFoundResponder = "\(child.expression)"
                case "redirects":
                    guard let array = child.expression.array else {
                        context.diagnose(DiagnosticMsg.expectedArrayExpr(expr: child.expression))
                        break
                    }
                    parseRedirects(context: context, version: version, array: array, staticRedirects: &storage.staticRedirects, dynamicRedirects: &storage.dynamicRedirects)
                case "middleware":
                    guard let elements = child.expression.array?.elements else {
                        context.diagnose(DiagnosticMsg.expectedArrayExpr(expr: child.expression))
                        break
                    }
                    for element in elements {
                        //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                        if let function = element.expression.functionCall {
                            let baseName = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
                            switch baseName {
                            case "StaticMiddleware":      storage.staticMiddleware.append(StaticMiddleware.parse(context: context, function))
                            default:
                                if let baseName, baseName.contains("Dynamic") && baseName.contains("Middleware") {
                                    if baseName == "DynamicMiddleware" {
                                        storage.upgradeExistentialDynamicMiddleware.append(function)
                                    } else {
                                        storage.dynamicMiddleware.append(function)
                                    }
                                } else {
                                    context.diagnose(DiagnosticMsg.unhandled(node: function.calledExpression))
                                }
                            }
                        } else if let _ = element.expression.macroExpansion {
                            // TODO: support custom middleware
                        } else {
                        }
                    }
                case "routeGroups":
                    guard let elements = child.expression.array?.elements else {
                        context.diagnose(DiagnosticMsg.expectedArrayExpr(expr: child.expression))
                        break
                    }
                    for element in elements {
                        if let function = element.expression.functionCall {
                            switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                            case "RouteGroup":
                                storage.routeGroups.append(RouteGroup.parse(
                                    context: context,
                                    version: version,
                                    staticMiddleware: storage.staticMiddleware,
                                    dynamicMiddleware: storage.dynamicMiddleware,
                                    function
                                ))
                            default:
                                context.diagnose(DiagnosticMsg.unhandled(node: function))
                            }
                        }
                    }
                default:
                    context.diagnose(DiagnosticMsg.unhandled(node: label))
                }
            } else if let function = child.expression.functionCall { // route
                computeRoute(context: context, version: version, function: function, &storage)
            } else {
                // TODO: support custom routes
                context.diagnose(DiagnosticMsg.unhandled(node: child))
            }
        }
        if staticNotFoundResponder.isEmpty {
            staticNotFoundResponder = try! ResponseBody.stringWithDateHeader("").responderDebugDescription(
                HTTPResponseMessage(
                    version: version,
                    status: HTTPStandardResponseStatus.notFound.code,
                    headers: [:],
                    cookies: [],
                    body: ResponseBody.stringWithDateHeader("not found"),
                    contentType: HTTPMediaType(HTTPMediaTypeText.plain),
                    charset: Charset.utf8
                )
            )
        }
        if dynamicNotFoundResponder == "nil" {
            dynamicNotFoundResponder = "Optional<DynamicRouteResponder>.none"
        }
        
        let routeGroupsString = storage.routeGroupsString(context: context)
        let conditionalRespondersString = storage.conditionalRespondersString()
        var string = "HTTPRouter("
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
        string += "\ncaseSensitiveResponders: \(caseSensitiveResponders),"
        string += "\ncaseInsensitiveResponders: \(caseInsensitiveResponders),"
        string += "\nstaticMiddleware: [\(storage.staticMiddlewareString())],"
        string += "\nopaqueDynamicMiddleware: [\(storage.dynamicMiddlewareString())],"
        string += "\nrouteGroups: [\(routeGroupsString)]"
        string += "\n)"
        return (string, storage.autoGeneratedStructs.joined(separator: "\n"))
    }
    private static func computeRoute(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        function: FunctionCallExprSyntax,
        _ storage: inout Storage
    ) {
        //print("Router;expansion;route;function=\(function.debugDescription)")
        let decl:String?
        var targetMethod:(any HTTPRequestMethodProtocol)? = nil
        if let member = function.calledExpression.memberAccess {
            decl = member.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            targetMethod = HTTPRequestMethod.parse(expr: member)
        } else {
            decl = function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        }
        switch decl {
        case "DynamicRoute":
            if var route = DynamicRoute.parse(context: context, version: version, middleware: storage.staticMiddleware, function) {
                if let method = targetMethod {
                    route.method = method
                }
                storage.dynamicRoutes.append((route, function))
            }
        case "StaticRoute":
            if var route = StaticRoute.parse(context: context, version: version, function) {
                if let method = targetMethod {
                    route.method = method
                }
                storage.staticRoutes.append((route, function))
            }
        case "StaticRedirectionRoute":
            if let route = StaticRedirectionRoute.parse(context: context, version: version, function) {
                storage.staticRedirects.append((route, function))
            }
        default:
            context.diagnose(DiagnosticMsg.unhandled(node: function.calledExpression))
        }
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
        var autoGeneratedStructs:[String] = []
        var autoGeneratedDynamicResponders:[String] = []
        var upgradeExistentialDynamicMiddleware:[FunctionCallExprSyntax] = []
        var dynamicMiddleware:[FunctionCallExprSyntax] = []
        var dynamicRedirects:[(any RedirectionRouteProtocol, SyntaxProtocol)] = []
        var dynamicRoutes:[(DynamicRoute, FunctionCallExprSyntax)] = []

        var staticMiddleware:[CompiledStaticMiddleware] = []
        var staticRedirects:[(any RedirectionRouteProtocol, SyntaxProtocol)] = []
        var staticRoutes:[(StaticRoute, FunctionCallExprSyntax)] = []
        
        var routeGroups:[any RouteGroupProtocol] = [] // TODO: refactor

        var conditionalResponders:[RoutePath:any ConditionalRouteResponderProtocol] = [:]
        var registeredPaths:Set<String> = []

        mutating func routeGroupsString(context: some MacroExpansionContext) -> String {
            return "" // TODO: refactor
            var string = ""
            if !routeGroups.isEmpty {
                string += "\n" + routeGroups.map({ "\($0)" }).joined(separator: ",\n") + "\n"
            }
            return string
        }

        func staticMiddlewareString() -> String {
            return staticMiddleware.isEmpty ? "" : "\n" + staticMiddleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        }

        lazy var autoGeneratedOpaqueDynamicMiddleware: String? = {
            guard !upgradeExistentialDynamicMiddleware.isEmpty else { return nil }
            for (i, function) in upgradeExistentialDynamicMiddleware.enumerated() {
                let functionString = "\(function.arguments.first!.expression.as(ClosureExprSyntax.self)!.statements)"
                let string = """
                struct AutoGeneratedOpaqueDynamicMiddleware\(i): OpaqueDynamicMiddlewareProtocol {

                    @inlinable
                    func customLogic(
                        request: inout some HTTPRequestProtocol & ~Copyable,
                        response: inout some DynamicResponseProtocol
                    ) async throws {
                        \(functionString)
                    }

                    @inlinable
                    func handle(
                        request: inout some HTTPRequestProtocol & ~Copyable,
                        response: inout some DynamicResponseProtocol
                    ) async throws -> Bool {
                        try await customLogic(request: &request, response: &response)
                        return true
                    }
                }
                """
                autoGeneratedStructs.append(string)
            }
            return ""
        }()

        mutating func dynamicMiddlewareString() -> String {
            var string = ""
            if autoGeneratedOpaqueDynamicMiddleware != nil {
                string += "\n\(upgradeExistentialDynamicMiddleware.enumerated().map({ "AutoGeneratedOpaqueDynamicMiddleware\($0.offset)()" }).joined(separator: ",\n")),\n"
            }
            if !dynamicMiddleware.isEmpty {
                string += "\n\(dynamicMiddleware.map({ "\($0)" }).joined(separator: ",\n"))\n"
            }
            return string
        }

        mutating func staticResponsesString(context: some MacroExpansionContext, caseSensitive: Bool) -> String {
            return staticRoutesString(
                context: context,
                isCaseSensitive: caseSensitive,
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
        array: ArrayExprSyntax,
        staticRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)],
        dynamicRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)]
    ) {
        for methodElement in array.elements {
            if let function = methodElement.expression.functionCall {
                switch methodElement.expression.functionCall?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                case "StaticRedirectionRoute":
                    if let route = StaticRedirectionRoute.parse(context: context, version: version, function) {
                        staticRedirects.append((route, function))
                    }
                default:
                    context.diagnose(DiagnosticMsg.unhandled(node: methodElement))
                }
            }
        }
    }
}

extension Router.Storage {
    struct Route {
        let path:String
        let buffer:DestinyRoutePathType
        let responder:String
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
        httpResponse: DestinyDefaults.HTTPResponseMessage
    ) {
        // TODO: refactor
        return;
        /*
        guard let result = httpResponse.body else { return }
        let body:[UInt8]
        do {
            body = try result.bytes()
        } catch {
            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPResponseMessage bytes: \(error).")))
            return
        }
        var httpResponse = httpResponse
        var responder = ConditionalRouteResponder(
            staticConditions: [],
            staticResponders: [],
            dynamicConditions: [],
            dynamicResponders: []
        )
        responder.staticConditionsDescription.removeLast() // ]
        responder.staticRespondersDescription.removeLast() // ]
        //responder.dynamicConditionsDescription.removeLast() // ] // TODO: support
        //responder.dynamicRespondersDescription.removeLast() // ]
        for algorithm in route.supportedCompressionAlgorithms {
            if let technique = algorithm.technique {
                do {
                    let compressed = try body.compressed(using: technique)
                    httpResponse.body = ResponseBody.bytes(compressed.data)
                    httpResponse.setHeader(key: HTTPResponseHeader.contentEncoding.rawNameString, value: algorithm.acceptEncodingName)
                    httpResponse.setHeader(key: HTTPResponseHeader.vary.rawNameString, value: HTTPRequestHeader.acceptEncoding.rawNameString)
                    do {
                        let bytes = try httpResponse.string(escapeLineBreak: false)
                        responder.staticConditionsDescription += "\n{ $0.headers[HTTPRequestHeader.acceptEncoding.rawNameString]?.contains(\"" + algorithm.acceptEncodingName + "\") ?? false }"
                        responder.staticRespondersDescription += "\n\(bytes)"
                    } catch {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPResponseMessage bytes using the " + algorithm.rawValue + " compression algorithm: \(error).")))
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
        conditionalResponders[RoutePath(comment: "// \(string)", path: buffer)] = responder*/
    }
}

// MARK: RoutePath
struct RoutePath: Hashable {
    let comment:String
    let path:DestinyRoutePathType
}
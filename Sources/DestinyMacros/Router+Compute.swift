
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

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

    private static func routeResponderStorage(staticResponses: String, dynamicResponses: String, conditionalResponses: String) -> String {
        var string = "RouterResponderStorage("
        string += "\nstatic: \(staticResponses),"
        string += "\ndynamic: \(dynamicResponses),"
        string += "\nconditional: [\(conditionalResponses)]"
        string += "\n)"
        return string
    }
}
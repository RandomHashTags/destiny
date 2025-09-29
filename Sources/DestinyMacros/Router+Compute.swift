
import DestinyBlueprint
import DestinyDefaults
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

#if NonEmbedded
import DestinyDefaultsNonEmbedded
#endif

extension Router {
    #if RouterSettings
    static func compute(
        routerSettings: RouterSettings,
        routerSettingsSyntax: ExprSyntax,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var compiledStorage = CompiledRouterStorage(routerSettings: routerSettings)
        var storage = RouterStorage(context: context, settings: routerSettings, perfectHashSettings: perfectHashSettings)
        return compute(compiledStorage: &compiledStorage, storage: &storage, routerSettingsSyntax: routerSettingsSyntax, arguments: arguments)
    }
    #else
    static func compute(
        routerSettingsSyntax: ExprSyntax,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var compiledStorage = CompiledRouterStorage()
        var storage = RouterStorage(context: context, perfectHashSettings: perfectHashSettings)
        return compute(compiledStorage: &compiledStorage, storage: &storage, routerSettingsSyntax: routerSettingsSyntax, arguments: arguments)
    }
    #endif

    static func compute(
        compiledStorage: inout CompiledRouterStorage,
        storage: inout RouterStorage,
        routerSettingsSyntax: ExprSyntax,
        arguments: LabeledExprListSyntax
    ) -> (router: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var version = HTTPVersion.v1_1
        var customErrorResponder = ""
        var customDynamicNotFoundResponder = ""
        var customStaticNotFoundResponder = ""
        for arg in arguments {
            if let label = arg.label {
                switch label.text {
                case "version":
                    version = HTTPVersion.parse(context: storage.context, expr: arg.expression) ?? version
                case "errorResponder":
                    customErrorResponder = "\(arg.expression)"
                case "dynamicNotFoundResponder":
                    customDynamicNotFoundResponder = "\(arg.expression)"
                case "staticNotFoundResponder":
                    customStaticNotFoundResponder = "\(arg.expression)"
                case "redirects":
                    guard let array = arg.expression.arrayElements(context: storage.context) else { break }
                    #if StaticRedirectionRoute
                    parseRedirects(
                        context: storage.context,
                        version: version,
                        array: array,
                        staticRedirects: &storage.staticRedirects,
                        dynamicRedirects: &storage.dynamicRedirects
                    )
                    #endif
                case "middleware":
                    guard let array = arg.expression.arrayElements(context: storage.context) else { break }
                    for element in array {
                        //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                        if let function = element.expression.functionCall {
                            parseMiddleware(context: storage.context, function: function, storage: &storage)
                        } else if let expansion = element.expression.macroExpansion {
                            // TODO: support custom middleware
                            storage.context.diagnose(DiagnosticMsg.unhandled(node: expansion))
                        } else {
                            storage.context.diagnose(DiagnosticMsg.unhandled(node: element))
                        }
                    }
                case "routeGroups":
                    guard let array = arg.expression.arrayElements(context: storage.context) else { break }
                    for element in array {
                        guard let function = element.expression.functionCall else {
                            storage.context.diagnose(DiagnosticMsg.unhandled(node: element))
                            continue
                        }
                        switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                        #if NonEmbedded && Copyable && MutableRouter
                        case "RouteGroup":
                            let (decl, groupStorage) = RouteGroup.parse(
                                context: storage.context,
                                settings: routerSettings,
                                perfectHashSettings: perfectHashSettings,
                                version: version,
                                staticMiddleware: storage.staticMiddleware,
                                dynamicMiddleware: storage.dynamicMiddleware,
                                storage: &storage,
                                function
                            )
                            storage.routeGroups.append(decl)
                            storage.generatedDecls.append(contentsOf: groupStorage.generatedDecls)
                            storage.upgradeExistentialDynamicMiddleware.append(contentsOf: groupStorage.upgradeExistentialDynamicMiddleware)
                        #endif

                        default:
                            storage.context.diagnose(DiagnosticMsg.unhandled(node: function))
                        }
                    }
                default:
                    break
                }
            } else if let function = arg.expression.functionCall { // route
                parseRoute(context: storage.context, version: version, function: function, storage: &storage)
            } else {
                // TODO: support custom routes
            }
        }

        let errorResponder:CompiledRouterStorage.Responder?
        if customErrorResponder.isEmpty || customErrorResponder.isEmpty || customErrorResponder == "nil" {
            let defaultStaticErrorResponse = GenericHTTPResponseMessage(
                version: version,
                status: 200, // ok
                headers: [:],
                cookies: [HTTPCookie](),
                body: "{\"error\":true,\"reason\":\"\\(error)\"}",
                contentType: "application/json",
                charset: nil
            ).string(escapeLineBreak: true)
            errorResponder = .get(
                defaultErrorResponder(isCopyable: true, response: defaultStaticErrorResponse),
                defaultErrorResponder(isCopyable: false, response: defaultStaticErrorResponse)
            )
        } else {
            errorResponder = .get(
                customErrorResponder,
                customErrorResponder
            )
        }

        let dynamicNotFoundResponder:CompiledRouterStorage.Responder?
        if customDynamicNotFoundResponder.isEmpty || customDynamicNotFoundResponder == "nil" {
            dynamicNotFoundResponder = nil
        } else {
            dynamicNotFoundResponder = .get(
                customDynamicNotFoundResponder,
                customDynamicNotFoundResponder
            )
        }

        let staticNotFoundResponder:CompiledRouterStorage.Responder?
        if customStaticNotFoundResponder.isEmpty || customStaticNotFoundResponder == "nil" {
            staticNotFoundResponder = .get(
                defaultStaticNotFoundResponder(version: version, isCopyable: true),
                defaultStaticNotFoundResponder(version: version, isCopyable: false)
            )
        } else {
            staticNotFoundResponder = .get(
                customStaticNotFoundResponder,
                customStaticNotFoundResponder
            )
        }

        let conditionalRespondersString = storage.conditionalRespondersString()

        let perfectHashCaseSensitiveResponder = storage.perfectHashResponder(isCaseSensitive: true)
        let perfectHashCaseInsensitiveResponder = storage.perfectHashResponder(isCaseSensitive: false)
        let caseSensitiveResponder:CompiledRouterStorage.Responder?
        let caseInsensitiveResponder:CompiledRouterStorage.Responder?
        let dynamicCaseSensitiveResponder:CompiledRouterStorage.Responder?
        let dynamicCaseInsensitiveResponder:CompiledRouterStorage.Responder?
        #if NonEmbedded
        caseSensitiveResponder = storage.staticRoutesResponder(isCaseSensitive: true)
        caseInsensitiveResponder = storage.staticRoutesResponder(isCaseSensitive: false)
        dynamicCaseSensitiveResponder = storage.dynamicRoutesResponder(isCaseSensitive: true)
        dynamicCaseInsensitiveResponder = storage.dynamicRoutesResponder(isCaseSensitive: false)
        #else
        caseSensitiveResponder = nil
        caseInsensitiveResponder = nil
        dynamicCaseSensitiveResponder = nil
        dynamicCaseInsensitiveResponder = nil
        #endif

        compiledStorage.perfectHashCaseSensitiveResponder = perfectHashCaseSensitiveResponder
        compiledStorage.perfectHashCaseInsensitiveResponder = perfectHashCaseInsensitiveResponder
        compiledStorage.caseSensitiveResponder = caseSensitiveResponder
        compiledStorage.caseInsensitiveResponder = caseInsensitiveResponder
        compiledStorage.dynamicCaseSensitiveResponder = dynamicCaseSensitiveResponder
        compiledStorage.dynamicCaseInsensitiveResponder = dynamicCaseInsensitiveResponder
        compiledStorage.dynamicMiddlewareArray = storage.dynamicMiddlewareArray()
        compiledStorage.errorResponder = errorResponder
        compiledStorage.dynamicNotFoundResponder = dynamicNotFoundResponder
        compiledStorage.staticNotFoundResponder = staticNotFoundResponder

        #if StaticMiddleware
        for (i, middleware) in storage.staticMiddleware.enumerated() {
            if !middleware.appliedAtLeastOnce {
                Diagnostic.unusedMiddleware(context: storage.context, node: storage.staticMiddlewareFunctions[i])
            }
        }
        #endif
        return (compiledStorage, storage.generatedDecls)
    }
    private static func defaultErrorResponder(
        isCopyable: Bool,
        response: String
    ) -> String {
        """
        \(responderCopyableValues(isCopyable: isCopyable).text)StaticErrorResponder({ error in
            \"\(response)\"
        })
        """
    }
    private static func defaultStaticNotFoundResponder(
        version: HTTPVersion,
        isCopyable: Bool
    ) -> String? {
        return IntermediateResponseBody(type: .staticStringWithDateHeader, "not found").responderDebugDescription(
            isCopyable: isCopyable,
            response: GenericHTTPResponseMessage(
                version: version,
                status: 404, // not found
                headers: ["date":HTTPDateFormat.placeholder],
                cookies: [HTTPCookie](),
                body: "not found",
                contentType: "text/plain",
                charset: Charset.utf8
            )
        )
    }
}
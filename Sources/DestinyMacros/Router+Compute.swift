
import DestinyBlueprint
import DestinyDefaults
import HTTPMediaTypes
import SwiftSyntax
import SwiftSyntaxMacros

#if MutableRouter && canImport(DestinyDefaultsNonEmbedded)
import DestinyDefaultsNonEmbedded
#endif

extension Router {
    static func compute(
        routerSettings: RouterSettings,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var version = HTTPVersion.v1_1
        var customErrorResponder = ""
        var customDynamicNotFoundResponder = ""
        var customStaticNotFoundResponder = ""
        var storage = RouterStorage(context: context, settings: routerSettings, perfectHashSettings: perfectHashSettings)
        for arg in arguments {
            if let label = arg.label {
                switch label.text {
                case "version":
                    version = HTTPVersion.parse(context: context, expr: arg.expression) ?? version
                case "errorResponder":
                    customErrorResponder = "\(arg.expression)"
                case "dynamicNotFoundResponder":
                    customDynamicNotFoundResponder = "\(arg.expression)"
                case "staticNotFoundResponder":
                    customStaticNotFoundResponder = "\(arg.expression)"
                case "redirects":
                    guard let array = arg.expression.arrayElements(context: context) else { break }
                    parseRedirects(
                        context: context,
                        version: version,
                        array: array,
                        staticRedirects: &storage.staticRedirects,
                        dynamicRedirects: &storage.dynamicRedirects
                    )
                case "middleware":
                    guard let array = arg.expression.arrayElements(context: context) else { break }
                    for element in array {
                        //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                        if let function = element.expression.functionCall {
                            parseMiddleware(context: context, function: function, storage: &storage)
                        } else if let expansion = element.expression.macroExpansion {
                            // TODO: support custom middleware
                            context.diagnose(DiagnosticMsg.unhandled(node: expansion))
                        } else {
                            context.diagnose(DiagnosticMsg.unhandled(node: element))
                        }
                    }
                case "routeGroups":
                    guard let array = arg.expression.arrayElements(context: context) else { break }
                    for element in array {
                        guard let function = element.expression.functionCall else {
                            context.diagnose(DiagnosticMsg.unhandled(node: element))
                            continue
                        }
                        switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                        #if MutableRouter && canImport(DestinyDefaultsNonEmbedded)
                        case "RouteGroup":
                            let (decl, groupStorage) = RouteGroup.parse(
                                context: context,
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
                            context.diagnose(DiagnosticMsg.unhandled(node: function))
                        }
                    }
                default:
                    break
                }
            } else if let function = arg.expression.functionCall { // route
                parseRoute(context: context, version: version, function: function, storage: &storage)
            } else {
                // TODO: support custom routes
            }
        }

        let errorResponder:CompiledRouterStorage.Responder?
        if customErrorResponder.isEmpty || customErrorResponder.isEmpty || customErrorResponder == "nil" {
            let defaultStaticErrorResponse = GenericHTTPResponseMessage(
                version: version,
                status: HTTPStandardResponseStatus.ok.code,
                headers: [:],
                cookies: [HTTPCookie](),
                body: "{\"error\":true,\"reason\":\"\\(error)\"}",
                contentType: HTTPMediaTypeApplication.json,
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
        let caseSensitiveResponder = storage.staticRoutesResponder(isCaseSensitive: true)
        let caseInsensitiveResponder = storage.staticRoutesResponder(isCaseSensitive: false)

        let dynamicCaseSensitiveResponder:CompiledRouterStorage.Responder?
        let dynamicCaseInsensitiveResponder:CompiledRouterStorage.Responder?
        #if canImport(DestinyDefaultsNonEmbedded)
        dynamicCaseSensitiveResponder = storage.dynamicRoutesResponder(isCaseSensitive: true)
        dynamicCaseInsensitiveResponder = storage.dynamicRoutesResponder(isCaseSensitive: false)
        #else
        dynamicCaseSensitiveResponder = nil
        dynamicCaseInsensitiveResponder = nil
        #endif

        let dynamicMiddlewareArray = storage.dynamicMiddlewareArray()
        let compiled = CompiledRouterStorage(
            settings: routerSettings,
            perfectHashCaseSensitiveResponder: perfectHashCaseSensitiveResponder,
            perfectHashCaseInsensitiveResponder: perfectHashCaseInsensitiveResponder,
            caseSensitiveResponder: caseSensitiveResponder,
            caseInsensitiveResponder: caseInsensitiveResponder,
            dynamicCaseSensitiveResponder: dynamicCaseSensitiveResponder,
            dynamicCaseInsensitiveResponder: dynamicCaseInsensitiveResponder,
            dynamicMiddlewareArray: dynamicMiddlewareArray,
            errorResponder: errorResponder,
            dynamicNotFoundResponder: dynamicNotFoundResponder,
            staticNotFoundResponder: staticNotFoundResponder
        )
        return (compiled, storage.generatedDecls)
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
                status: HTTPStandardResponseStatus.notFound.code,
                headers: ["Date":HTTPDateFormat.placeholder],
                cookies: [HTTPCookie](),
                body: "not found",
                contentType: HTTPMediaType(HTTPMediaTypeText.plain),
                charset: Charset.utf8
            )
        )
    }
}
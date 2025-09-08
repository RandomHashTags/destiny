
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension Router {
    static func compute(
        routerSettings: RouterSettings,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: CompiledRouterStorage, structs: [any DeclSyntaxProtocol]) {
        var version = HTTPVersion.v1_1
        var customErrorResponder = ""
        var customDynamicNotFoundResponder = ""
        var customStaticNotFoundResponder = ""
        var storage = RouterStorage(settings: routerSettings, perfectHashSettings: perfectHashSettings)
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
                        if let function = element.expression.functionCall {
                            switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
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
                            default:
                                context.diagnose(DiagnosticMsg.unhandled(node: function))
                            }
                        } else {
                            context.diagnose(DiagnosticMsg.unhandled(node: element))
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

        let errorResponder:(copyable: String?, noncopyable: String?)?
        if customErrorResponder.isEmpty || customErrorResponder.isEmpty || customErrorResponder == "nil" {
            let defaultStaticErrorResponse = HTTPResponseMessage(
                version: version,
                status: HTTPStandardResponseStatus.ok.code,
                headers: [:],
                cookies: [],
                body: "{\"error\":true,\"reason\":\"\\(error)\"}",
                contentType: HTTPMediaTypeApplication.json,
                charset: nil
            ).string(escapeLineBreak: true)
            errorResponder = (
                defaultErrorResponder(isCopyable: true, response: defaultStaticErrorResponse),
                defaultErrorResponder(isCopyable: false, response: defaultStaticErrorResponse)
            )
        } else {
            errorResponder = (
                customErrorResponder,
                customErrorResponder
            )
        }

        let dynamicNotFoundResponder:(copyable: String?, noncopyable: String?)?
        if customDynamicNotFoundResponder.isEmpty || customDynamicNotFoundResponder == "nil" {
            dynamicNotFoundResponder = nil
        } else {
            dynamicNotFoundResponder = (
                customDynamicNotFoundResponder,
                customDynamicNotFoundResponder
            )
        }

        let staticNotFoundResponder:(copyable: String?, noncopyable: String?)?
        if customStaticNotFoundResponder.isEmpty || customStaticNotFoundResponder == "nil" {
            staticNotFoundResponder = (
                defaultStaticNotFoundResponder(version: version, isCopyable: true),
                defaultStaticNotFoundResponder(version: version, isCopyable: false)
            )
        } else {
            staticNotFoundResponder = (
                customStaticNotFoundResponder,
                customStaticNotFoundResponder
            )
        }

        let conditionalRespondersString = storage.conditionalRespondersString()

        let perfectHashCaseSensitiveResponders = storage.perfectHashStorage(mutable: false, context: context, isCaseSensitive: true)
        let perfectHashCaseInsensitiveResponders = storage.perfectHashStorage(mutable: false, context: context, isCaseSensitive: false)
        let caseSensitiveResponders = storage.staticResponsesSyntax(mutable: false, context: context, isCaseSensitive: true)
        let caseInsensitiveResponders = storage.staticResponsesSyntax(mutable: false, context: context, isCaseSensitive: false)
        let dynamicCaseSensitiveResponders = storage.dynamicResponsesString(mutable: false, context: context, isCaseSensitive: true)
        let dynamicCaseInsensitiveResponders = storage.dynamicResponsesString(mutable: false, context: context, isCaseSensitive: false)

        let dynamicMiddlewareArray = storage.dynamicMiddlewareArray(mutable: false)
        let compiled = CompiledRouterStorage(
            settings: routerSettings,
            perfectHashCaseSensitiveResponder: .get(perfectHashCaseSensitiveResponders),
            perfectHashCaseInsensitiveResponder: .get(perfectHashCaseInsensitiveResponders),
            caseSensitiveResponder: .get(caseSensitiveResponders),
            caseInsensitiveResponder: .get(caseInsensitiveResponders),
            dynamicCaseSensitiveResponder: .get(dynamicCaseSensitiveResponders),
            dynamicCaseInsensitiveResponder: .get(dynamicCaseInsensitiveResponders),
            dynamicMiddlewareArray: dynamicMiddlewareArray,
            errorResponder: .get(errorResponder),
            dynamicNotFoundResponder: .get(dynamicNotFoundResponder),
            staticNotFoundResponder: .get(staticNotFoundResponder)
        )
        return (compiled, storage.generatedDecls)
    }
    private static func defaultErrorResponder(
        isCopyable: Bool,
        response: String
    ) -> String {
        """
        \(isCopyable ? "" : "NonCopyable")StaticErrorResponder({ error in
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
            response: HTTPResponseMessage(
                version: version,
                status: HTTPStandardResponseStatus.notFound.code,
                headers: ["Date":HTTPDateFormat.placeholder],
                cookies: [],
                body: "not found",
                contentType: HTTPMediaType(HTTPMediaTypeText.plain),
                charset: Charset.utf8
            )
        )
    }
}
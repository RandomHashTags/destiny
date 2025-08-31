
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension Router {
    static func compute(
        visibility: RouterVisibility,
        mutable: Bool,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (router: CompiledRouterStorage, structs: [any DeclSyntaxProtocol]) {
        var version = HTTPVersion.v1_1
        var errorResponder = ""
        var dynamicNotFoundResponder:String? = nil
        var staticNotFoundResponder:String? = nil
        var storage = RouterStorage(visibility: visibility, perfectHashSettings: perfectHashSettings)
        for child in arguments {
            if let label = child.label {
                switch label.text {
                case "version":
                    version = HTTPVersion.parse(context: context, expr: child.expression) ?? version
                case "errorResponder":
                    errorResponder = "\(child.expression)"
                case "dynamicNotFoundResponder":
                    dynamicNotFoundResponder = "\(child.expression)"
                case "staticNotFoundResponder":
                    staticNotFoundResponder = "\(child.expression)"
                case "redirects":
                    guard let array = child.expression.arrayElements(context: context) else { break }
                    parseRedirects(context: context, version: version, array: array, staticRedirects: &storage.staticRedirects, dynamicRedirects: &storage.dynamicRedirects)
                case "middleware":
                    guard let array = child.expression.arrayElements(context: context) else { break }
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
                    guard let array = child.expression.arrayElements(context: context) else { break }
                    for element in array {
                        if let function = element.expression.functionCall {
                            switch function.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                            case "RouteGroup":
                                let (decl, groupStorage) = RouteGroup.parse(
                                    context: context,
                                    visibility: visibility,
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
            } else if let function = child.expression.functionCall { // route
                parseRoute(context: context, version: version, function: function, storage: &storage)
            } else {
                // TODO: support custom routes
            }
        }
        if errorResponder.isEmpty {
            let defaultStaticErrorResponse = HTTPResponseMessage(
                version: version,
                status: HTTPStandardResponseStatus.ok.code,
                headers: [:],
                cookies: [],
                body: "{\"error\":true,\"reason\":\"\\(error)\"}",
                contentType: HTTPMediaTypeApplication.json,
                charset: nil
            ).string(escapeLineBreak: true)
            errorResponder = """
            StaticErrorResponder({ error in
                \"\(defaultStaticErrorResponse)\"
            })
            """
        }
        if staticNotFoundResponder == nil || staticNotFoundResponder!.isEmpty {
            staticNotFoundResponder = IntermediateResponseBody(type: .staticStringWithDateHeader, "not found").responderDebugDescription(
                HTTPResponseMessage(
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

        let conditionalRespondersString = storage.conditionalRespondersString()

        let perfectHashCaseSensitiveResponders = storage.perfectHashStorage(mutable: false, context: context, caseSensitive: true)
        let perfectHashCaseInsensitiveResponders = storage.perfectHashStorage(mutable: false, context: context, caseSensitive: false)
        var caseSensitiveResponders:String? = nil
        var caseInsensitiveResponders:String? = nil
        var dynamicCaseSensitiveResponder:String? = nil
        var dynamicCaseInsensitiveResponder:String? = nil
        if let s = storage.staticResponsesSyntax(mutable: false, context: context, caseSensitive: true) {
            caseSensitiveResponders = s
        }
        if let s = storage.staticResponsesSyntax(mutable: false, context: context, caseSensitive: false) {
            caseInsensitiveResponders = s
        }
        if let s = storage.dynamicResponsesString(mutable: false, context: context, caseSensitive: true) {
            dynamicCaseSensitiveResponder = s
        }
        if let s = storage.dynamicResponsesString(mutable: false, context: context, caseSensitive: false) {
            dynamicCaseInsensitiveResponder = s
        }

        let dynamicMiddlewareArray = storage.dynamicMiddlewareArray(mutable: false)
        let compiled = CompiledRouterStorage(
            visibility: visibility,
            perfectHashCaseSensitiveResponder: perfectHashCaseSensitiveResponders,
            perfectHashCaseInsensitiveResponder: perfectHashCaseInsensitiveResponders,
            caseSensitiveResponder: caseSensitiveResponders,
            caseInsensitiveResponder: caseInsensitiveResponders,
            dynamicCaseSensitiveResponder: dynamicCaseSensitiveResponder,
            dynamicCaseInsensitiveResponder: dynamicCaseInsensitiveResponder,
            dynamicMiddlewareArray: dynamicMiddlewareArray,
            errorResponder: errorResponder,
            dynamicNotFoundResponder: dynamicNotFoundResponder,
            staticNotFoundResponder: staticNotFoundResponder
        )
        return (compiled, storage.generatedDecls)
    }
}
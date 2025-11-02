
import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension Router {
    #if RouterSettings
    static func compute(
        routerSettings: RouterSettings,
        routerSettingsSyntax: ExprSyntax,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (storage: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var compiledStorage = CompiledRouterStorage(routerSettings: routerSettings)
        var storage = RouterStorage(settings: routerSettings, perfectHashSettings: perfectHashSettings)
        return compute(context: context, compiledStorage: &compiledStorage, storage: &storage, routerSettingsSyntax: routerSettingsSyntax, args: arguments)
    }
    #else
    static func compute(
        routerSettingsSyntax: ExprSyntax,
        perfectHashSettings: PerfectHashSettings,
        arguments: LabeledExprListSyntax,
        context: some MacroExpansionContext
    ) -> (storage: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        var compiledStorage = CompiledRouterStorage()
        var storage = RouterStorage(perfectHashSettings: perfectHashSettings)
        return compute(context: context, compiledStorage: &compiledStorage, storage: &storage, routerSettingsSyntax: routerSettingsSyntax, args: arguments)
    }
    #endif

    static func compute(
        context: some MacroExpansionContext,
        compiledStorage: inout CompiledRouterStorage,
        storage: inout RouterStorage,
        routerSettingsSyntax: ExprSyntax,
        args: LabeledExprListSyntax
    ) -> (storage: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        let (version, customErrorResponder, customDynamicNotFoundResponder, customStaticNotFoundResponder) = parseArguments(
            context: context,
            args: args,
            storage: &storage
        )

        let errorResponder:CompiledRouterStorage.Responder?
        if customErrorResponder.isEmpty || customErrorResponder.isEmpty || customErrorResponder == "nil" {
            let status:HTTPResponseStatus.Code = 200 // ok
            let headers:HTTPHeaders = [:]
            let body = "{\"error\":true,\"reason\":\"\\(error)\"}"
            let contentType = "application/json"
            let defaultStaticErrorResponse:String

            #if HTTPCookie
            defaultStaticErrorResponse = HTTPResponseMessage.init(
                head: .init(headers: headers, cookies: [], status: status, version: version),
                body: body,
                contentType: contentType,
                charset: nil
            ).string(escapeLineBreak: true)
            #else
            defaultStaticErrorResponse = HTTPResponseMessage.init(
                head: .init(headers: headers, status: status, version: version),
                body: body,
                contentType: contentType,
                charset: nil
            ).string(escapeLineBreak: true)
            #endif

            errorResponder = .get(
                defaultErrorResponder(isCopyable: true, response: defaultStaticErrorResponse, storage: &storage),
                defaultErrorResponder(isCopyable: false, response: defaultStaticErrorResponse, storage: &storage)
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
                defaultStaticNotFoundResponder(context: context, version: version, isCopyable: true),
                defaultStaticNotFoundResponder(context: context, version: version, isCopyable: false)
            )
        } else {
            staticNotFoundResponder = .get(
                customStaticNotFoundResponder,
                customStaticNotFoundResponder
            )
        }

        let perfectHashCaseSensitiveResponder = storage.perfectHashResponder(context: context, isCaseSensitive: true)
        let perfectHashCaseInsensitiveResponder = storage.perfectHashResponder(context: context, isCaseSensitive: false)
        let caseSensitiveResponder:CompiledRouterStorage.Responder?
        let caseInsensitiveResponder:CompiledRouterStorage.Responder?
        let dynamicCaseSensitiveResponder:CompiledRouterStorage.Responder?
        let dynamicCaseInsensitiveResponder:CompiledRouterStorage.Responder?

        caseSensitiveResponder = storage.staticRoutesResponder(context: context, isCaseSensitive: true)
        caseInsensitiveResponder = storage.staticRoutesResponder(context: context, isCaseSensitive: false)
        dynamicCaseSensitiveResponder = storage.dynamicRoutesResponder(context: context, isCaseSensitive: true)
        dynamicCaseInsensitiveResponder = storage.dynamicRoutesResponder(context: context, isCaseSensitive: false)

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
                Diagnostic.unusedMiddleware(context: context, node: storage.staticMiddlewareFunctions[i].calledExpression)
            }
        }
        #endif
        return (compiledStorage, storage.generatedDecls)
    }
}

// MARK: Parse arguments
extension Router {
    private static func parseArguments(
        context: some MacroExpansionContext,
        args: LabeledExprListSyntax,
        storage: inout RouterStorage
    ) -> (
        version: HTTPVersion,
        customErrorResponder: String,
        customDynamicNotFoundResponder: String,
        customStaticNotFoundResponder: String
    ) {
        var version = HTTPVersion.v1_1
        var customErrorResponder = ""
        var customDynamicNotFoundResponder = ""
        var customStaticNotFoundResponder = ""
        for arg in args {
            guard let label = arg.label?.text else {
                if let function = arg.expression.functionCall { // route
                    parseRoute(context: context, version: version, function: function, storage: &storage)
                } else {
                    // TODO: support custom routes
                }
                continue
            }
            switch label {
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
                #if StaticRedirectionRoute
                parseRedirects(
                    context: context,
                    version: version,
                    array: array,
                    staticRedirects: &storage.staticRedirects
                )
                #endif
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
                    #if NonEmbedded && RouteGroup
                    case "RouteGroup":
                        let (decl, groupStorage) = RouteGroup.parse(
                            context: context,
                            settings: storage.settings,
                            perfectHashSettings: storage.perfectHashSettings,
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
        }
        return (
            version,
            customErrorResponder,
            customDynamicNotFoundResponder,
            customStaticNotFoundResponder
        )
    }
}

// MARK: Default error responder
extension Router {
    private static func defaultErrorResponder(
        isCopyable: Bool,
        response: String,
        storage: inout RouterStorage
    ) -> String {
        let copyableSymbol:String, copyableText:String, routerType:String
        if isCopyable {
            copyableSymbol = ""
            copyableText = ""
            routerType = "some HTTPRouterProtocol"
        } else {
            copyableSymbol = "~"
            copyableText = "NonCopyable"
            routerType = "borrowing some NonCopyableHTTPRouterProtocol & ~Copyable"
        }
        let name = "\(copyableText)ErrorResponder"

        var members = MemberBlockItemListSyntax()
        members.append(try! FunctionDeclSyntax("""
        public func respond(
            provider: some SocketProvider,
            router: \(raw: routerType),
            error: some Error,
            request: inout HTTPRequest
        ) {
            #if DEBUG && Logging
            router.logger.warning("\\(error)")
            #endif
            do throws(ResponderError) {
                let errorDesc = "\\(error)"
                let contentLength = errorDesc.count
                let responder = \(raw: defaultErrorResponder())
                try responder.respond(provider: provider, router: router, request: &request)
            } catch {
                #if Logging
                router.logger.error("[\(raw: name)] Encountered error trying to write response: \\(error)")
                #endif
            }
        }
        """))
        let decl = StructDeclSyntax(
            leadingTrivia: "// MARK: \(name)\n",
            modifiers: [storage.visibilityModifier],
            name: "\(raw: name)",
            inheritanceClause: .init(inheritedTypes: [
                .init(type: TypeSyntax(stringLiteral: "Sendable"), trailingComma: .commaToken()),
                .init(type: TypeSyntax(stringLiteral: "\(copyableSymbol)Copyable"))
            ]),
            memberBlock: .init(members: members)
        )
        storage.generatedDecls.append(decl)
        return name + "()"
    }
    private static func defaultErrorResponder() -> String {
        """
        StringWithDateHeader(
            preDateValue: "HTTP/1.1 200\\r\\ndate: ",
            postDateValue: "\\r\\ncontent-type: application/json\\r\\ncontent-length: \\(contentLength)",
            value: "{\\"error\\":true,\\"reason\\":\\"\\(errorDesc)\\"}"
        )
        """
    }
    private static func defaultStaticNotFoundResponder(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        isCopyable: Bool
    ) -> String? {
        let status:HTTPResponseStatus.Code = 404 // not found
        let headers = HTTPHeaders(["date":HTTPDateFormat.placeholder])
        let body = "not found"
        let contentType = "text/plain"
        let charset = Charset.utf8
        let stringLiteral = StringLiteralExprSyntax(content: body)
        let intermediateBody = IntermediateResponseBody(type: .staticStringWithDateHeader, .init(stringLiteral))
        #if hasFeature(Embedded) || EMBEDDED
            let response:HTTPResponseMessage<String>

            #if HTTPCookie
            response = .init(
                head: .init(headers: headers, cookies: [], status: status, version: version),
                body: body,
                contentType: contentType,
                charset: charset
            )
            #else
            response = .init(
                head: .init(headers: headers, status: status, version: version),
                body: body,
                contentType: contentType,
                charset: charset
            )
            #endif

        #else
            let response:HTTPResponseMessage

            #if HTTPCookie
            response = HTTPResponseMessage(
                head: .init(headers: headers, cookies: [], status: status, version: version),
                body: body,
                contentType: contentType,
                charset: charset
            )
            #else
            response = HTTPResponseMessage(
                head: .init(headers: headers, status: status, version: version),
                body: body,
                contentType: contentType,
                charset: charset
            )
            #endif

        #endif
        return intermediateBody.responderDebugDescription(
            context: context,
            isCopyable: isCopyable,
            response: response
        )
    }
}
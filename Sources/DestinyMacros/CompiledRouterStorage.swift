
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct CompiledRouterStorage {
    let settings:RouterSettings
    let settingsSyntax:ExprSyntax
    let perfectHashCaseSensitiveResponder:Responder?
    let perfectHashCaseInsensitiveResponder:Responder?

    let caseSensitiveResponder:Responder?
    let caseInsensitiveResponder:Responder?

    let dynamicCaseSensitiveResponder:Responder?
    let dynamicCaseInsensitiveResponder:Responder?

    let dynamicMiddlewareArray:[String]

    let errorResponder:Responder?
    let dynamicNotFoundResponder:Responder?
    let staticNotFoundResponder:Responder?

    let visibilityModifier:DeclModifierSyntax
    let requestTypeSyntax:TypeSyntax

    init(
        settings: RouterSettings,
        settingsSyntax: ExprSyntax,
        perfectHashCaseSensitiveResponder: Responder?,
        perfectHashCaseInsensitiveResponder: Responder?,

        caseSensitiveResponder: Responder?,
        caseInsensitiveResponder: Responder?,
        dynamicCaseSensitiveResponder: Responder?,
        dynamicCaseInsensitiveResponder: Responder?,

        dynamicMiddlewareArray: [String],

        errorResponder: Responder?,
        dynamicNotFoundResponder: Responder?,
        staticNotFoundResponder: Responder?
    ) {
        self.settings = settings
        self.settingsSyntax = settingsSyntax
        self.perfectHashCaseSensitiveResponder = perfectHashCaseSensitiveResponder
        self.perfectHashCaseInsensitiveResponder = perfectHashCaseInsensitiveResponder

        self.caseSensitiveResponder = caseSensitiveResponder
        self.caseInsensitiveResponder = caseInsensitiveResponder
        self.dynamicCaseSensitiveResponder = dynamicCaseSensitiveResponder
        self.dynamicCaseInsensitiveResponder = dynamicCaseInsensitiveResponder

        self.dynamicMiddlewareArray = dynamicMiddlewareArray

        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        visibilityModifier = settings.visibility.modifierDecl
        requestTypeSyntax = settings.requestTypeSyntax
    }
    
    var visibility: RouterVisibility {
        settings.visibility
    }
}

// MARK: Responder
extension CompiledRouterStorage {
    struct Responder {
        static func get(_ copyable: String?, _ noncopyable: String?) -> Responder? {
            return copyable != nil || noncopyable != nil ? .init(copyable: copyable, noncopyable: noncopyable) : nil
        }

        let copyable:String?
        let noncopyable:String?
    }
}

// MARK: Build
extension CompiledRouterStorage {
    /// Builds the compiled router which stores _up-to_ 3 independent routers, each with separate performance and functionality characteristics.
    /// 
    /// - Immutable `~Copyable` router (optimal performance)
    ///   - e.g., when both the route path and its response are known at compile time (doesn't support concurrency)
    /// - Immutable `Copyable` router (trades some performance for concurrency support)
    ///   - e.g., when both the route path and its response are known at compile time (supports concurrency)
    /// - Mutable router (sacrificing performance for runtime functionality)
    ///   - e.g., registering middleware, routes, route groups, and route responders at runtime
    func build(context: some MacroExpansionContext) -> StructDeclSyntax {
        let copyable = buildSubRouter(isCopyable: true)
        let noncopyable = buildSubRouter(isCopyable: false)

        #if !Copyable
        if copyable != nil {
            context.diagnose(Diagnostic(
                node: settingsSyntax,
                message: DiagnosticMsg(
                    id: "copyablePackageTraitNeededButNotEnables",
                    message: "Router contains copyable components but the `Copyable` package trait isn't enabled",
                    severity: .warning
                )
            ))
        }
        #endif

        #if !NonCopyable
        if noncopyable != nil {
            context.diagnose(Diagnostic(
                node: settingsSyntax,
                message: DiagnosticMsg(
                    id: "noncopyablePackageTraitNeededButNotEnables",
                    message: "Router contains noncopyable components but the `NonCopyable` package trait isn't enabled",
                    severity: .warning
                )
            ))
        }
        #endif

        var members = MemberBlockItemListSyntax()

        // merge single router with the compiled router
        if !settings.isMutable && (copyable == nil && noncopyable != nil || copyable != nil && noncopyable == nil) {
            if let copyable {
                members = copyable.memberBlock.members
            } else if let noncopyable {
                members = noncopyable.memberBlock.members
            }
        } else { // handle multiple routers (2 or more)
            buildMultiRouter(members: &members, copyable: copyable, noncopyable: noncopyable)
        }
        let name = settings.name
        return .init(
            leadingTrivia: "// MARK: \(name)\n",
            modifiers: [visibilityModifier],
            name: "\(raw: name)",
            inheritanceClause: .init(
                inheritedTypes: routerProtocolConformances(isCopyable: settings.isCopyable, protocolConformance: settings.hasProtocolConformances)
            ),
            memberBlock: .init(members: members)
        )
    }

    private func buildSubRouter(
        isCopyable: Bool
    ) -> StructDeclSyntax? {
        guard let variableDecls = variableDecls(isCopyable: isCopyable) else { return nil }
        var members = MemberBlockItemListSyntax()
        members.append(contentsOf: variableDecls.map({ .init(decl: $0) }))
        members.append(loadDecl())
        members.append(handleDynamicMiddlewareDecl())
        members.append(handleDecl())
        members.append(respondDecl(isCopyable: isCopyable))
        members.append(respondWithStaticResponderDecl(isCopyable: isCopyable))
        members.append(defaultDynamicResponseDecl(isCopyable: isCopyable))
        members.append(respondWithDynamicResponderDecl(isCopyable: isCopyable))
        members.append(respondWithNotFoundDecl())
        members.append(respondWithErrorDecl())

        let name:String
        if isCopyable {
            name = "Copyable"
        } else {
            name = "NonCopyable"
        }
        return .init(
            leadingTrivia: "// MARK: \(name)\n#if \(name)\n",
            modifiers: [visibilityModifier],
            name: "\(raw: "_\(name)")",
            inheritanceClause: .init(
                inheritedTypes: routerProtocolConformances(isCopyable: isCopyable, protocolConformance: settings.hasProtocolConformances)
            ),
            memberBlock: .init(members: members),
            trailingTrivia: "\n#endif"
        )
    }
}

// MARK: Multi-router
extension CompiledRouterStorage {
    private func buildMultiRouter(
        members: inout MemberBlockItemListSyntax,
        copyable: StructDeclSyntax?,
        noncopyable: StructDeclSyntax?
    ) {
        var routerVariableNames = [(trait: String, variableName: String)]()
        if noncopyable != nil {
            routerVariableNames.append(("NonCopyable", "noncopyable"))
            let noncopyableDecl = VariableDeclSyntax(
                leadingTrivia: "#if NonCopyable\n",
                modifiers: [visibilityModifier],
                .let,
                name: "noncopyable",
                initializer: .init(value: ExprSyntax("_NonCopyable()"), trailingTrivia: "\n#endif")
            )
            members.append(noncopyableDecl)
        }
        if copyable != nil {
            routerVariableNames.append(("Copyable", "copyable"))
            let copyableDecl = VariableDeclSyntax.init(
                leadingTrivia: "#if Copyable\n",
                modifiers: [visibilityModifier],
                .let,
                name: "copyable",
                initializer: .init(value: ExprSyntax("_Copyable()"), trailingTrivia: "\n#endif"),
            )
            members.append(copyableDecl)
        }

        let mutable:ClassDeclSyntax?
        if settings.isMutable {
            routerVariableNames.append(("MutableRouter", "mutable"))
            let mutableDecl = VariableDeclSyntax(
                modifiers: [visibilityModifier],
                .let,
                name: "mutable",
                initializer: .init(value: ExprSyntax("_Mutable()"))
            )
            members.append(mutableDecl)
            mutable = buildMutableRouter()
        } else {
            mutable = nil
        }

        let loggerDecl = VariableDeclSyntax(
            leadingTrivia: "#if Logging\n",
            modifiers: [visibilityModifier],
            .let,
            name: "logger",
            initializer: .init(value: ExprSyntax("Logger(label: \"compiledHTTPRouter\")"), trailingTrivia: "\n#endif"),
        )
        members.append(loggerDecl)

        let loadString = routerVariableNames.map({
            "#if \($0.trait)\n\($0.variableName).load()\n#endif"
        }).joined(separator: "\n")
        members.append(loadDecl(loadString: loadString))

        let handleDynamicMiddlewareString = routerVariableNames.map({
            "#if \($0.trait)\ntry \($0.variableName).handleDynamicMiddleware(for: &request, with: &response)\n#endif"
        }).joined(separator: "\n")
        members.append(handleDynamicMiddlewareDecl(handleString: handleDynamicMiddlewareString))

        members.append(handleDecl())

        let respondersString = routerVariableNames.map({
            "#if \($0.trait)\nif try \($0.variableName).respond(socket: socket, request: &request, completionHandler: completionHandler) {\nreturn true\n}\n#endif"
        }).joined(separator: "\n") + "\nreturn false\n"
        members.append(respondDecl(respondersString: respondersString))

        members.append(respondWithStaticResponderDecl(isCopyable: false, responderString: "completionHandler()"))
        members.append(respondWithDynamicResponderDecl(isCopyable: false, responderString: "completionHandler()"))

        let respondWithNotFoundString = routerVariableNames.map({
            "#if \($0.trait)\nif try \($0.variableName).respondWithNotFound(socket: socket, request: &request, completionHandler: completionHandler) {\nreturn true\n}\n#endif"
        }).joined(separator: "\n") + "\nreturn false\n"
        members.append(respondWithNotFoundDecl(responderString: respondWithNotFoundString))

        let respondWithErrorString = routerVariableNames.map({
            "#if \($0.trait)\nif \($0.variableName).respondWithError(socket: socket, error: error, request: &request, completionHandler: completionHandler) {\nreturn true\n}\n#endif"
        }).joined(separator: "\n") + "\nreturn false\n"
        members.append(respondWithErrorDecl(logic: respondWithErrorString))

        if let noncopyable {
            members.append(noncopyable)
        }
        if let copyable {
            members.append(copyable)
        }
        if let mutable {
            members.append(mutable)
        }
    }
}

// MARK: Mutable router
extension CompiledRouterStorage {
    private func buildMutableRouter() -> ClassDeclSyntax {
        var members = MemberBlockItemListSyntax()

        // variables
        let responders:[(String, String)] = [
            ("caseSensitiveStatic", "StaticResponderStorage"),
            ("caseInsensitiveStatic", "CaseInsensitiveStaticResponderStorage"),
            ("caseSensitiveDynamic", "DynamicResponderStorage"),
            ("caseInsensitiveDynamic", "DynamicResponderStorage"),
            ("routeGroups", "RouteGroupStorage"),
        ]
        for (responderVariableName, responderType) in responders {
            members.append(.init(decl: VariableDeclSyntax(
                modifiers: [visibilityModifier],
                .let,
                name: PatternSyntax(stringLiteral: responderVariableName),
                initializer: .init(value: ExprSyntax("\(raw: responderType)()"))
            )))
        }
        members.append(.init(decl: VariableDeclSyntax(
            modifiers: [visibilityModifier],
            .var,
            name: "dynamicMiddleware",
            initializer: .init(value: ExprSyntax("[any DynamicMiddlewareProtocol]()"))
        )))

        let loggerDecl = VariableDeclSyntax(
            leadingTrivia: "#if Logging\n",
            modifiers: [visibilityModifier],
            .let,
            name: "logger",
            initializer: .init(value: ExprSyntax("Logger(label: \"mutableHTTPRouter\")"), trailingTrivia: "\n#endif")
        )
        members.append(loggerDecl)

        // functions
        members.append(loadDecl())

        let handleDynamicMiddlewareString = ""
        members.append(handleDynamicMiddlewareDecl(handleString: handleDynamicMiddlewareString))

        members.append(handleDecl())

        members.append(respondDecl(respondersString: respondString(responders: responders.map({ $0.0 }))))

        members.append(respondWithStaticResponderDecl(isCopyable: true, responderString: "try responder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)"))
        members.append(respondWithDynamicResponderDecl(isCopyable: true, responderString: "try responder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)"))

        members.append(respondWithNotFoundDecl(responderString: "return false"))

        members.append(respondWithErrorDecl(logic: """
        #if Logging
        logger.error("[StaticErrorResponder] // TODO: NOT YET IMPLEMENTED!")
        #endif
        return false
        """))

        members.append(.init(decl: FunctionDeclSyntax(
            modifiers: [visibilityModifier],
            name: "register",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "caseSensitive", type: TypeSyntax("Bool"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "path", type: TypeSyntax("SIMD64<UInt8>"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "responder", type: TypeSyntax("some StaticRouteResponderProtocol"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "override", type: TypeSyntax("Bool"), trailingTrivia: "\n")
                ]),
            ),
            body: .init(statements: [])
        )))

        members.append(.init(decl: FunctionDeclSyntax(
            modifiers: [visibilityModifier],
            name: "register",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "caseSensitive", type: TypeSyntax("Bool"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "route", type: TypeSyntax("some DynamicRouteProtocol"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "responder", type: TypeSyntax("some DynamicRouteResponderProtocol"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "override", type: TypeSyntax("Bool"), trailingTrivia: "\n")
                ])
            ),
            body: .init(statements: [])
        )))

        return .init(
            leadingTrivia: "// MARK: _Mutable\n",
            modifiers: [visibilityModifier, .init(name: .keyword(.final))],
            name: "_Mutable",
            inheritanceClause: .init(inheritedTypes: .init([
                .init(type: TypeSyntax("HTTPMutableRouterProtocol"), trailingComma: .commaToken()),
                .init(type: TypeSyntax("@unchecked Sendable"))
            ])),
            memberBlock: .init(members: members)
        )
    }
}

// MARK: Variable decls
extension CompiledRouterStorage {
    private func variableDecls(isCopyable: Bool) -> [VariableDeclSyntax]? {
        var decls = [VariableDeclSyntax]()
        let appendVariableResponderFunction:(String, Responder) -> Void
        let loggerPrefix:String
        if isCopyable {
            appendVariableResponderFunction = { name, responder in 
                guard let copyable = responder.copyable else { return }
                decls.append(.init(
                    modifiers: [visibilityModifier],
                    .let,
                    name: "\(raw: name)",
                    initializer: .init(value: ExprSyntax(stringLiteral: copyable)), 
                ))
            }
            loggerPrefix = "copyable"
        } else {
            appendVariableResponderFunction = { name, responder in
                guard let noncopyable = responder.noncopyable else { return }
                decls.append(.init(
                    modifiers: [visibilityModifier],
                    .let,
                    name: "\(raw: name)",
                    initializer: .init(value: ExprSyntax(stringLiteral: noncopyable)), 
                ))
            }
            loggerPrefix = "noncopyable"
        }
        if let perfectHashCaseSensitiveResponder {
            appendVariableResponderFunction("perfectHashCaseSensitiveResponder", perfectHashCaseSensitiveResponder)
        }
        if let perfectHashCaseInsensitiveResponder {
            appendVariableResponderFunction("perfectHashCaseInsensitiveResponder", perfectHashCaseInsensitiveResponder)
        }

        if let caseSensitiveResponder {
            appendVariableResponderFunction("caseSensitiveResponder", caseSensitiveResponder)
        }
        if let caseInsensitiveResponder {
            appendVariableResponderFunction("caseInsensitiveResponder", caseInsensitiveResponder)
        }

        if let dynamicCaseSensitiveResponder {
            appendVariableResponderFunction("dynamicCaseSensitiveResponder", dynamicCaseSensitiveResponder)
        }
        if let dynamicCaseInsensitiveResponder {
            appendVariableResponderFunction("dynamicCaseInsensitiveResponder", dynamicCaseInsensitiveResponder)
        }
        guard !decls.isEmpty else { return nil }

        if !dynamicMiddlewareArray.isEmpty {
            let dynamicMiddleware = "(\n\(dynamicMiddlewareArray.joined(separator: ",\n"))\n)"
            decls.append(.init(
                modifiers: [visibilityModifier],
                .let,
                name: "dynamicMiddleware",
                initializer: .init(value: ExprSyntax(stringLiteral: dynamicMiddleware))
            ))
        }

        if let errorResponder {
            appendVariableResponderFunction("errorResponder", errorResponder)
        }
        if let dynamicNotFoundResponder {
            appendVariableResponderFunction("dynamicNotFoundResponder", dynamicNotFoundResponder)
        }
        if let staticNotFoundResponder {
            appendVariableResponderFunction("staticNotFoundResponder", staticNotFoundResponder)
        }
        decls.append(.init(
            leadingTrivia: "#if Logging\n",
            modifiers: [visibilityModifier],
            .let,
            name: "logger",
            initializer: .init(value: ExprSyntax(stringLiteral: "Logger(label: \"compiledHTTPRouter.\(loggerPrefix)HTTPRouter\")"), trailingTrivia: "\n#endif")
        ))
        return decls
    }
}

// MARK: Load decl
extension CompiledRouterStorage {
    private func loadDecl() -> FunctionDeclSyntax {
        return loadDecl(loadString: "")
    }
    private func loadDecl(loadString: String) -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "load",
            signature: .init(parameterClause: .init(parameters: .init())),
            body: .init(statements: .init(stringLiteral: loadString))
        )
    }
}

// MARK: Handle dynamic middleware
extension CompiledRouterStorage {
    private func handleDynamicMiddlewareDecl() -> FunctionDeclSyntax {
        let handleString = dynamicMiddlewareArray.enumerated().map({
            "guard try dynamicMiddleware.\($0.offset).handle(request: &request, response: &response) else { return }"
        }).joined(separator: "\n")
        return handleDynamicMiddlewareDecl(handleString: handleString)
    }
    private func handleDynamicMiddlewareDecl(handleString: String) -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            name: "handleDynamicMiddleware",
            signature: .init(
                parameterClause: .init(parameters: .init([
                    .init(leadingTrivia: "\n", firstName: "for", secondName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "with", secondName: "response", type: TypeSyntax(stringLiteral: "inout some DynamicResponseProtocol"), trailingTrivia: "\n")
                ])),
                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws), leftParen: .leftParenToken(), type: TypeSyntax("MiddlewareError"), rightParen: .rightParenToken()))
            ),
            body: .init(statements: .init(stringLiteral: handleString))
        )
    }
}

// MARK: Handle decl
extension CompiledRouterStorage {
    private func handleDecl() -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "handle",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "client", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("consuming some HTTPSocketProtocol & ~Copyable"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n")
                ])
            ),
            body: .init(statements: .init(stringLiteral: """
                do throws(SocketError) {
                    var request = try \(settings.requestType).load(from: socket)

                    #if DEBUG && Logging
                    let requestStartLine = try request.startLine().stringSIMD()
                    logger.info("\\(requestStartLine)")
                    #endif

                    do throws(ResponderError) {
                        guard !(try respond(socket: client, request: &request, completionHandler: completionHandler)) else { return }
                        if !(try respondWithNotFound(socket: client, request: &request, completionHandler: completionHandler)) {
                            #if Logging
                            logger.error("failed to send response to client")
                            #endif
                            completionHandler()
                        }
                    } catch {
                        #if Logging
                        logger.warning("Encountered error while processing client: \\(error)")
                        #endif
                        if !respondWithError(socket: client, error: error, request: &request, completionHandler: completionHandler) {
                            #if Logging
                            logger.error("failed to send response to client")
                            #endif
                            completionHandler()
                        }
                    }
                } catch {
                    #if Logging
                    logger.warning("Encountered error while loading request: \\(error)")
                    #endif
                    completionHandler()
                }
                """)
            )
        )
    }
}

// MARK: Respond decl
extension CompiledRouterStorage {
    private func respondDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        var responders = [String]()
        let appendResponder:(String, Responder) -> Void
        if isCopyable {
            appendResponder = { name, responder in
                guard responder.copyable != nil else { return }
                responders.append(name)
            }
        } else {
            appendResponder = { name, responder in
                guard responder.noncopyable != nil else { return }
                responders.append(name)
            }
        }
        if let perfectHashCaseSensitiveResponder {
            appendResponder("perfectHashCaseSensitiveResponder", perfectHashCaseSensitiveResponder)
        }
        if let perfectHashCaseInsensitiveResponder {
            appendResponder("perfectHashCaseInsensitiveResponder", perfectHashCaseInsensitiveResponder)
        }
        if let caseSensitiveResponder {
            appendResponder("caseSensitiveResponder", caseSensitiveResponder)
        }
        if let caseInsensitiveResponder {
            appendResponder("caseInsensitiveResponder", caseInsensitiveResponder)
        }
        if let dynamicCaseSensitiveResponder {
            appendResponder("dynamicCaseSensitiveResponder", dynamicCaseSensitiveResponder)
        }
        if let dynamicCaseInsensitiveResponder {
            appendResponder("dynamicCaseInsensitiveResponder", dynamicCaseInsensitiveResponder)
        }
        return respondDecl(respondersString: respondString(responders: responders))
    }
    private func respondString(responders: [String]) -> String {
        return responders.map({
            "if try \($0).respond(router: self, socket: socket, request: &request, completionHandler: completionHandler) {\n"
        }).joined(separator: "} else ") + "} else {\nreturn false\n}\nreturn true"
    }
    private func respondDecl(respondersString: String) -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "respond",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n"),
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(throwsSpecifier: "throws", leftParen: .leftParenToken(), type: TypeSyntax("ResponderError"), rightParen: .rightParenToken())
                ),
                returnClause: .init(type: TypeSyntax("Bool"))
            ),
            body: .init(statements: .init(stringLiteral: respondersString))
        )
    }
}

// MARK: Respond with static responder decl
extension CompiledRouterStorage {
    private func respondWithStaticResponderDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        return respondWithStaticResponderDecl(isCopyable: isCopyable, responderString: """
        try responder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)
        """)
    }
    private func respondWithStaticResponderDecl(isCopyable: Bool, responderString: String) -> FunctionDeclSyntax {
        let responderParameter = RouterStorage.responderParameter(copyable: isCopyable, dynamic: false)
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "respond",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "responder", type: TypeSyntax(stringLiteral: responderParameter), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n")
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(throwsSpecifier: "throws", leftParen: .leftParenToken(), type: TypeSyntax("ResponderError"), rightParen: .rightParenToken())
                )
            ),
            body: .init(statements: .init(stringLiteral: responderString))
        )
    }
}

// MARK: Default dynamic response decl
extension CompiledRouterStorage {
    private func defaultDynamicResponseDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        let responderParameter = RouterStorage.responderParameter(copyable: isCopyable, dynamic: true)
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "defaultDynamicResponse",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "responder", type: TypeSyntax(stringLiteral: responderParameter), trailingTrivia: "\n")
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(throwsSpecifier: "throws", leftParen: .leftParenToken(), type: TypeSyntax("ResponderError"), rightParen: .rightParenToken())
                ),
                returnClause: .init(type: TypeSyntax("some DynamicResponseProtocol"))
            ),
            body: .init(statements: .init(stringLiteral: """
                var response = responder.defaultResponse()
                var index = 0
                let maximumParameters = responder.pathComponentsCount
                var err:SocketError? = nil
                responder.forEachPathComponentParameterIndex { parameterIndex in
                    let pathAtIndex:String
                    do throws(SocketError) {
                        pathAtIndex = try request.path(at: parameterIndex)
                    } catch {
                        err = error
                        return
                    }
                    pathAtIndex.inlineVLArray {
                        response.setParameter(at: index, value: $0)
                    }
                    if responder.pathComponent(at: parameterIndex) == .catchall {
                        do throws(SocketError) {
                            var i = parameterIndex+1
                            try request.forEachPath(offset: i) { path in
                                path.inlineVLArray {
                                    if i < maximumParameters {
                                        response.setParameter(at: i, value: $0)
                                    } else {
                                        response.appendParameter(value: $0)
                                    }
                                }
                                i += 1
                            }
                        } catch {
                            err = error
                            return
                        }
                        
                    }
                    index += 1
                }
                if let err {
                    throw .socketError(err)
                }
                return response
                """)
            )
        )
    }
}

// MARK: Respond with dynamic responder decl
extension CompiledRouterStorage {
    private func respondWithDynamicResponderDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        return respondWithDynamicResponderDecl(isCopyable: isCopyable, responderString: """
        var response = try defaultDynamicResponse(request: &request, responder: responder)
        do throws(MiddlewareError) {
            try handleDynamicMiddleware(for: &request, with: &response)
        } catch {
            throw .middlewareError(error)
        }
        try responder.respond(router: self, socket: socket, request: &request, response: &response, completionHandler: completionHandler)
        """)
    }
    private func respondWithDynamicResponderDecl(isCopyable: Bool, responderString: String) -> FunctionDeclSyntax {
        let responderParameter = RouterStorage.responderParameter(copyable: isCopyable, dynamic: true)
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "respond",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "responder", type: TypeSyntax(stringLiteral: responderParameter), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n"),
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(throwsSpecifier: "throws", leftParen: .leftParenToken(), type: TypeSyntax("ResponderError"), rightParen: .rightParenToken())
                )
            ),
            body: .init(statements: .init(stringLiteral: responderString))
        )
    }
}

// MARK: Respond with not found decl
extension CompiledRouterStorage {
    private func respondWithNotFoundDecl() -> FunctionDeclSyntax {
        var responder:String? = nil
        if dynamicNotFoundResponder != nil {
            responder = """
            var response = try defaultDynamicResponse(request: &request, responder: dynamicNotFoundResponder)
            try dynamicNotFoundResponder.respond(router: self, socket: socket, request: &request, response: &response, completionHandler: completionHandler)
            return true
            """
        } else if staticNotFoundResponder != nil {
            responder = """
            try staticNotFoundResponder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)
            return true
            """
        }
        return respondWithNotFoundDecl(responderString: """
        \(responder ?? "return false")
        """)
    }
    private func respondWithNotFoundDecl(responderString: String) -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "respondWithNotFound",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n"),
                ]),
                effectSpecifiers: .init(
                    throwsClause: .init(throwsSpecifier: "throws", leftParen: .leftParenToken(), type: TypeSyntax("ResponderError"), rightParen: .rightParenToken())
                ),
                returnClause: .init(type: TypeSyntax("Bool"))
            ),
            body: .init(statements: .init(stringLiteral: responderString))
        )
    }
}

// MARK: Respond with error decl
extension CompiledRouterStorage {
    private func respondWithErrorDecl() -> FunctionDeclSyntax {
        let logic:String
        if errorResponder != nil {
            logic = """
            errorResponder.respond(router: self, socket: socket, error: error, request: &request, completionHandler: completionHandler)
            return true
            """
        } else {
            logic = "return false"
        }
        return respondWithErrorDecl(logic: logic)
    }
    private func respondWithErrorDecl(logic: String) -> FunctionDeclSyntax {
        return .init(
            leadingTrivia: "\(inlinableAnnotation)\n",
            modifiers: [visibilityModifier],
            name: "respondWithError",
            signature: .init(
                parameterClause: .init(parameters: [
                    .init(leadingTrivia: "\n", firstName: "socket", type: TypeSyntax("some FileDescriptor"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "error", type: TypeSyntax("some Error"), trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "request", type: requestTypeSyntax, trailingComma: .commaToken()),
                    .init(leadingTrivia: "\n", firstName: "completionHandler", type: TypeSyntax("@Sendable @escaping () -> Void"), trailingTrivia: "\n"),
                ]),
                returnClause: .init(type: TypeSyntax("Bool"))
            ),
            body: .init(statements: .init(stringLiteral: logic))
        )
    }
}
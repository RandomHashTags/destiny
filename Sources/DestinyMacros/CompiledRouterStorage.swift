
import DestinyBlueprint
import SwiftSyntax
import SwiftSyntaxMacros

struct CompiledRouterStorage {
    let settings:RouterSettings
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

    init(
        settings: RouterSettings,
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
    }
    
    var visibility: RouterVisibility {
        settings.visibility
    }
}

// MARK: Responder
extension CompiledRouterStorage {
    struct Responder {
        static func get(_ values: (copyable: String?, noncopyable: String?)?) -> Responder? {
            guard let values else { return nil }
            return values.copyable != nil || values.noncopyable != nil ? .init(copyable: values.copyable, noncopyable: values.noncopyable) : nil
        }

        let copyable:String?
        let noncopyable:String?
    }
}

// MARK: Build
extension CompiledRouterStorage {
    func build() -> StructDeclSyntax {
        let name = settings.name
        var decl = StructDeclSyntax(
            leadingTrivia: "// MARK: \(name)\n\(visibility)",
            name: "\(raw: name)",
            inheritanceClause: .init(inheritedTypes: .init(arrayLiteral: 
                .init(type: TypeSyntax(stringLiteral: "\(settings.isCopyable ? "" : "NonCopyable")HTTPRouterProtocol"), trailingComma: ","),
                .init(type: TypeSyntax(stringLiteral: "\(settings.isCopyable ? "" : "~")Copyable"))
            )),
            memberBlock: .init(members: .init())
        )
        let copyable = buildSubRouter(isCopyable: true)
        let noncopyable = buildSubRouter(isCopyable: false)
        if copyable == nil && noncopyable != nil || copyable != nil && noncopyable == nil { // merge single router with the compiled router
            if let copyable {
                decl.memberBlock.members.append(contentsOf: copyable.memberBlock.members)
            } else if let noncopyable {
                decl.memberBlock.members.append(contentsOf: noncopyable.memberBlock.members)
            }
        } else { // handle multiple routers
            buildMultiRouter(decl: &decl, copyable: copyable, noncopyable: noncopyable)
        }
        return decl
    }

    private func buildSubRouter(isCopyable: Bool) -> StructDeclSyntax? {
        var decl = StructDeclSyntax(
            leadingTrivia: "// MARK: \(isCopyable ? "Copyable" : "NonCopyable")\n\(visibility)",
            name: "\(raw: "_\(isCopyable ? "Copyable" : "NonCopyable")")",
            inheritanceClause: .init(inheritedTypes: .init(arrayLiteral: 
                .init(type: TypeSyntax(stringLiteral: "\(isCopyable ? "" : "NonCopyable")HTTPRouterProtocol"), trailingComma: ","),
                .init(type: TypeSyntax(stringLiteral: "\(isCopyable ? "" : "~")Copyable"))
            )),
            memberBlock: .init(members: .init())
        )

        guard let variableDecls = variableDecls(isCopyable: isCopyable) else { return nil }
        decl.memberBlock.members.append(contentsOf: variableDecls.map({ .init(decl: $0) }))
        decl.memberBlock.members.append(.init(decl: loadDecl()))
        decl.memberBlock.members.append(.init(decl: handleDynamicMiddlewareDecl()))
        decl.memberBlock.members.append(.init(decl: handleDecl()))
        decl.memberBlock.members.append(.init(decl: respondDecl(isCopyable: isCopyable)))
        decl.memberBlock.members.append(.init(decl: respondWithStaticResponderDecl(isCopyable: isCopyable)))
        decl.memberBlock.members.append(.init(decl: defaultDynamicResponseDecl(isCopyable: isCopyable)))
        decl.memberBlock.members.append(.init(decl: respondWithDynamicResponderDecl(isCopyable: isCopyable)))
        decl.memberBlock.members.append(.init(decl: respondWithNotFoundDecl()))
        decl.memberBlock.members.append(.init(decl: respondWithErrorDecl()))
        return decl
    }
}

// MARK: Multi-router
extension CompiledRouterStorage {
    private func buildMultiRouter(
        decl: inout StructDeclSyntax,
        copyable: StructDeclSyntax?,
        noncopyable: StructDeclSyntax?
    ) {
        let copyableDecl = VariableDeclSyntax(
            .let,
            name: "copyable",
            initializer: .init(value: ExprSyntax("_Copyable()"))
        )
        let noncopyableDecl = VariableDeclSyntax(
            .let,
            name: "noncopyable",
            initializer: .init(value: ExprSyntax("_NonCopyable()"))
        )
        decl.memberBlock.members.append(.init(decl: copyableDecl))
        decl.memberBlock.members.append(.init(decl: noncopyableDecl))

        let loggerDecl = VariableDeclSyntax(
            .let,
            name: "logger",
            initializer: .init(value: ExprSyntax("Logger(label: \"compiledHTTPRouter\")"))
        )
        decl.memberBlock.members.append(.init(decl: loggerDecl))

        decl.memberBlock.members.append(.init(decl: loadDecl(loadString: """
        noncopyable.load()
        copyable.load()
        """)))

        decl.memberBlock.members.append(.init(decl: handleDynamicMiddlewareDecl(handleString: """
        try noncopyable.handleDynamicMiddleware(for: &request, with: &response)
        try copyable.handleDynamicMiddleware(for: &request, with: &response)
        """)))

        decl.memberBlock.members.append(.init(decl: handleDecl()))
        decl.memberBlock.members.append(.init(decl: respondDecl(respondersString: """
        if try noncopyable.respond(socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try copyable.respond(socket: socket, request: &request, completionHandler: completionHandler) {
        } else {
            return false
        }
        """)))

        decl.memberBlock.members.append(.init(decl: respondWithStaticResponderDecl(isCopyable: false, responderString: "completionHandler()")))
        decl.memberBlock.members.append(.init(decl: respondWithDynamicResponderDecl(isCopyable: false, responderString: "completionHandler()")))

        decl.memberBlock.members.append(.init(decl: respondWithNotFoundDecl(responderString: """
        if try noncopyable.respondWithNotFound(socket: socket, request: &request, completionHandler: completionHandler) {
        } else if try copyable.respondWithNotFound(socket: socket, request: &request, completionHandler: completionHandler) {
        } else {
            return false
        }
        return true
        """)))

        decl.memberBlock.members.append(.init(decl: respondWithErrorDecl(logic: """
        if noncopyable.respondWithError(socket: socket, error: error, request: &request, completionHandler: completionHandler) {
        } else if copyable.respondWithError(socket: socket, error: error, request: &request, completionHandler: completionHandler) {
        } else {
            return false
        }
        return true
        """)))

        if let copyable {
            decl.memberBlock.members.append(.init(decl: copyable))
        }
        if let noncopyable {
            decl.memberBlock.members.append(.init(decl: noncopyable))
        }
    }
}

// MARK: Variable decls
extension CompiledRouterStorage {
    private func variableDecls(isCopyable: Bool) -> [VariableDeclSyntax]? {
        var decls = [VariableDeclSyntax]()
        if let perfectHashCaseSensitiveResponder {
            appendVariableResponders(name: "perfectHashCaseSensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: perfectHashCaseSensitiveResponder)
        }
        if let perfectHashCaseInsensitiveResponder {
            appendVariableResponders(name: "perfectHashCaseInsensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: perfectHashCaseInsensitiveResponder)
        }

        if let caseSensitiveResponder {
            appendVariableResponders(name: "caseSensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: caseSensitiveResponder)

        }
        if let caseInsensitiveResponder {
            appendVariableResponders(name: "caseInsensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: caseInsensitiveResponder)
        }

        if let dynamicCaseSensitiveResponder {
            appendVariableResponders(name: "dynamicCaseSensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: dynamicCaseSensitiveResponder)

        }
        if let dynamicCaseInsensitiveResponder {
            appendVariableResponders(name: "dynamicCaseInsensitiveResponder", isCopyable: isCopyable, decls: &decls, responder: dynamicCaseInsensitiveResponder)
        }
        guard !decls.isEmpty else { return nil }

        if !dynamicMiddlewareArray.isEmpty {
            let dynamicMiddleware = "(\n\(dynamicMiddlewareArray.joined(separator: ",\n"))\n)"
            try! decls.append(.init("""
            \(raw: visibility)let dynamicMiddleware = \(raw: dynamicMiddleware)
            """))
        }

        if let errorResponder {
            appendVariableResponders(name: "errorResponder", isCopyable: isCopyable, decls: &decls, responder: errorResponder)
        }
        if let dynamicNotFoundResponder {
            appendVariableResponders(name: "dynamicNotFoundResponder", isCopyable: isCopyable, decls: &decls, responder: dynamicNotFoundResponder)
        }
        if let staticNotFoundResponder {
            appendVariableResponders(name: "staticNotFoundResponder", isCopyable: isCopyable, decls: &decls, responder: staticNotFoundResponder)
        }
        try! decls.append(.init("""
        \(raw: visibility)let logger = Logger(label: "compiledHTTPRouter.\(raw: isCopyable ? "copyable" : "noncopyable")HTTPRouter")
        """))
        return decls
    }
    private func appendVariableResponders(
        name: String,
        isCopyable: Bool,
        decls: inout [VariableDeclSyntax],
        responder: Responder
    ) {
        if isCopyable, let copyable = responder.copyable {
            try! decls.append(.init("""
            \(raw: visibility)let \(raw: name) = \(raw: copyable)
            """))
        }
        if !isCopyable, let noncopyable = responder.noncopyable {
            try! decls.append(.init("""
            \(raw: visibility)let \(raw: name) = \(raw: noncopyable)
            """))
        }
    }
}

// MARK: Load decl
extension CompiledRouterStorage {
    private func loadDecl() -> FunctionDeclSyntax {
        var loadString = dynamicMiddlewareArray.enumerated().map({
            "dynamicMiddleware.\($0.offset).load()"
        }).joined(separator: "\n")
        loadString = "// TODO: fix?\n/*\n\(loadString)\n*/"
        return loadDecl(loadString: loadString)
    }
    private func loadDecl(loadString: String) -> FunctionDeclSyntax {
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func load() {
            \(raw: loadString)
        }
        """)
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
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func handleDynamicMiddleware(
            for request: inout some HTTPRequestProtocol & ~Copyable,
            with response: inout some DynamicResponseProtocol
        ) throws(MiddlewareError) {
            \(raw: handleString)
        }
        """)
    }
}

// MARK: Handle decl
extension CompiledRouterStorage {
    private func handleDecl() -> FunctionDeclSyntax {
        try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func handle(
            client: some FileDescriptor,
            socket: consuming some HTTPSocketProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) {
            do throws(SocketError) {
                var request = try \(raw: settings.requestType).load(from: socket)

                #if DEBUG
                let requestStartLine = try request.startLine().stringSIMD()
                logger.info("\\(requestStartLine)")
                #endif

                do throws(ResponderError) {
                    guard !(try respond(socket: client, request: &request, completionHandler: completionHandler)) else { return }
                    if !(try respondWithNotFound(socket: client, request: &request, completionHandler: completionHandler)) {
                        logger.error("failed to send response to client")
                        completionHandler()
                    }
                } catch {
                    logger.warning("Encountered error while processing client: \\(error)")
                    if !respondWithError(socket: client, error: error, request: &request, completionHandler: completionHandler) {
                        logger.error("failed to send response to client")
                        completionHandler()
                    }
                }
            } catch {
                logger.warning("Encountered error while loading request: \\(error)")
                completionHandler()
            }
        }
        """)
    }
}

// MARK: Respond decl
extension CompiledRouterStorage {
    private func respondDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        var responders = [String]()
        if let perfectHashCaseSensitiveResponder {
            appendResponder(name: "perfectHashCaseSensitiveResponder", isCopyable: isCopyable, responder: perfectHashCaseSensitiveResponder, responders: &responders)
        }
        if let perfectHashCaseInsensitiveResponder {
            appendResponder(name: "perfectHashCaseInsensitiveResponder", isCopyable: isCopyable, responder: perfectHashCaseInsensitiveResponder, responders: &responders)
        }
        if let caseSensitiveResponder {
            appendResponder(name: "caseSensitiveResponder", isCopyable: isCopyable, responder: caseSensitiveResponder, responders: &responders)
        }
        if let caseInsensitiveResponder {
            appendResponder(name: "caseInsensitiveResponder", isCopyable: isCopyable, responder: caseInsensitiveResponder, responders: &responders)
        }
        if let dynamicCaseSensitiveResponder {
            appendResponder(name: "dynamicCaseSensitiveResponder", isCopyable: isCopyable, responder: dynamicCaseSensitiveResponder, responders: &responders)
        }
        if let dynamicCaseInsensitiveResponder {
            appendResponder(name: "dynamicCaseInsensitiveResponder", isCopyable: isCopyable, responder: dynamicCaseInsensitiveResponder, responders: &responders)
        }
        var respondersString = responders.map({
            "try \($0).respond(router: self, socket: socket, request: &request, completionHandler: completionHandler) {"
        }).joined(separator: "\n} else if ")
        if !respondersString.isEmpty {
            respondersString = "if \(respondersString)\n} else {\nreturn false\n}"
        }
        return respondDecl(respondersString: respondersString)
    }
    private func respondDecl(respondersString: String) -> FunctionDeclSyntax {
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respond(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            \(raw: respondersString)
            return true
        }
        """)
    }
    private func appendResponder(
        name: String,
        isCopyable: Bool,
        responder: Responder,
        responders: inout [String]
    ) {
        if isCopyable, responder.copyable != nil {
            responders.append(name)
        }
        if !isCopyable, responder.noncopyable != nil {
            responders.append(name)
        }
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
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respond(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: \(raw: responderParameter),
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) {
            \(raw: responderString)
        }
        """)
    }
}

// MARK: Default dynamic response decl
extension CompiledRouterStorage {
    private func defaultDynamicResponseDecl(isCopyable: Bool) -> FunctionDeclSyntax {
        let responderParameter = RouterStorage.responderParameter(copyable: isCopyable, dynamic: true)
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func defaultDynamicResponse(
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: \(raw: responderParameter)
        ) throws(ResponderError) -> some DynamicResponseProtocol {
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
        }
        """)
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
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respond(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: \(raw: responderParameter),
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) {
            \(raw: responderString)
        }
        """)
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
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respondWithNotFound(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            \(raw: responderString)
        }
        """)
    }
}

// MARK: Respond with error decl
extension CompiledRouterStorage {
    private func respondWithErrorDecl() -> FunctionDeclSyntax {
        let logic:String
        if errorResponder != nil {
            logic = """
            errorResponder.respond(router: self, socket: socket, error: error, request: &request, logger: logger, completionHandler: completionHandler)
            return true
            """
        } else {
            logic = "return false"
        }
        return respondWithErrorDecl(logic: logic)
    }
    private func respondWithErrorDecl(logic: String) -> FunctionDeclSyntax {
        return try! .init("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respondWithError(
            socket: some FileDescriptor,
            error: some Error,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) -> Bool {
            \(raw: logic)
        }
        """)
    }
}
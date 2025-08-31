
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

struct CompiledRouterStorage {
    let visibility:RouterVisibility
    let perfectHashCaseSensitiveResponder:String?
    let perfectHashCaseInsensitiveResponder:String?

    let caseSensitiveResponder:String?
    let caseInsensitiveResponder:String?

    let dynamicCaseSensitiveResponder:String?
    let dynamicCaseInsensitiveResponder:String?

    let dynamicMiddlewareArray:[String]

    let errorResponder:String?
    let dynamicNotFoundResponder:String?
    let staticNotFoundResponder:String?

    init(
        visibility: RouterVisibility,
        perfectHashCaseSensitiveResponder: String?,
        perfectHashCaseInsensitiveResponder: String?,

        caseSensitiveResponder: String?,
        caseInsensitiveResponder: String?,
        dynamicCaseSensitiveResponder: String?,
        dynamicCaseInsensitiveResponder: String?,

        dynamicMiddlewareArray: [String],

        errorResponder: String?,
        dynamicNotFoundResponder: String?,
        staticNotFoundResponder: String?
    ) {
        self.visibility = visibility
        self.perfectHashCaseSensitiveResponder = perfectHashCaseSensitiveResponder
        self.perfectHashCaseInsensitiveResponder = perfectHashCaseInsensitiveResponder

        self.caseSensitiveResponder = caseSensitiveResponder
        self.caseInsensitiveResponder = caseInsensitiveResponder
        self.dynamicCaseSensitiveResponder = dynamicCaseSensitiveResponder
        self.dynamicCaseInsensitiveResponder = dynamicCaseInsensitiveResponder

        self.dynamicMiddlewareArray = dynamicMiddlewareArray

        self.errorResponder = errorResponder == "nil" ? nil : errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder == "nil" ? nil : dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder == "nil" ? nil : staticNotFoundResponder
    }
}

// MARK: x

// MARK: Build
extension CompiledRouterStorage {
    func build() -> StructDeclSyntax {
        var decl = StructDeclSyntax(
            leadingTrivia: "// MARK: CompiledHTTPRouter\n\(visibility)",
            name: "CompiledHTTPRouter",
            inheritanceClause: .init(inheritedTypes: .init(arrayLiteral: 
                .init(type: TypeSyntax(stringLiteral: "HTTPRouterProtocol"))
            )),
            memberBlock: .init(members: .init())
        )
        decl.memberBlock.members.append(contentsOf: variableDecls().map({ .init(decl: $0) }))
        decl.memberBlock.members.append(.init(decl: loadDecl()))
        decl.memberBlock.members.append(.init(decl: handleDynamicMiddlewareDecl()))
        decl.memberBlock.members.append(.init(decl: handleDecl()))
        decl.memberBlock.members.append(.init(decl: respondDecl()))
        decl.memberBlock.members.append(.init(decl: respondWithStaticResponderDecl()))
        decl.memberBlock.members.append(.init(decl: defaultDynamicResponseDecl()))
        decl.memberBlock.members.append(.init(decl: respondWithDynamicResponderDecl()))
        decl.memberBlock.members.append(.init(decl: respondWithNotFoundDecl()))
        decl.memberBlock.members.append(.init(decl: respondWithErrorDecl()))
        return decl
    }
}

// MARK: Variable decls
extension CompiledRouterStorage {
    private func variableDecls() -> [VariableDeclSyntax] {
        var decls = [VariableDeclSyntax]()
        if let perfectHashCaseSensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let perfectHashCaseSensitiveResponder = \(raw: perfectHashCaseSensitiveResponder)
            """))
        }
        if let perfectHashCaseInsensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let perfectHashCaseInsensitiveResponder = \(raw: perfectHashCaseInsensitiveResponder)
            """))
        }

        if let caseSensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let caseSensitiveResponder = \(raw: caseSensitiveResponder)
            """))
        }
        if let caseInsensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let caseInsensitiveResponder = \(raw: caseInsensitiveResponder)
            """))
        }

        if let dynamicCaseSensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let dynamicCaseSensitiveResponder = \(raw: dynamicCaseSensitiveResponder)
            """))
        }
        if let dynamicCaseInsensitiveResponder {
            try! decls.append(.init("""
            \(raw: visibility)let dynamicCaseInsensitiveResponder = \(raw: dynamicCaseInsensitiveResponder)
            """))
        }

        if !dynamicMiddlewareArray.isEmpty {
            let dynamicMiddleware = "(\n\(dynamicMiddlewareArray.joined(separator: ",\n"))\n)"
            try! decls.append(.init("""
            \(raw: visibility)let dynamicMiddleware = \(raw: dynamicMiddleware)
            """))
        }

        if let errorResponder {
            try! decls.append(.init("""
            \(raw: visibility)let errorResponder = \(raw: errorResponder)
            """))
        }
        if let dynamicNotFoundResponder {
            try! decls.append(.init("""
            \(raw: visibility)let dynamicNotFoundResponder = \(raw: dynamicNotFoundResponder)
            """))
        }
        if let staticNotFoundResponder {
            try! decls.append(.init("""
            \(raw: visibility)let staticNotFoundResponder = \(raw: staticNotFoundResponder)
            """))
        }
        try! decls.append(.init("""
        \(raw: visibility)let logger = Logger(label: "compiledHTTPRouter")
        """))
        return decls
    }
}

// MARK: Load decl
extension CompiledRouterStorage {
    private func loadDecl() -> FunctionDeclSyntax {
        let loadString = dynamicMiddlewareArray.enumerated().map({
            "dynamicMiddleware.\($0.offset).load()"
        }).joined(separator: "\n")
        return try! .init("""
        @inlinable
        \(raw: visibility)func load() {
            // TODO: fix?
            /*
            \(raw: loadString)
            */
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
        return try! .init("""
        @inlinable
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
        @inlinable
        \(raw: visibility)func handle(
            client: some FileDescriptor,
            socket: consuming some HTTPSocketProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) {
            do throws(SocketError) {
                var request = try socket.loadRequest()

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
    private func respondDecl() -> FunctionDeclSyntax {
        var responders = [String]()
        if perfectHashCaseSensitiveResponder != nil {
            responders.append("perfectHashCaseSensitiveResponder")
        }
        if perfectHashCaseInsensitiveResponder != nil {
            responders.append("perfectHashCaseInsensitiveResponder")
        }
        if caseSensitiveResponder != nil {
            responders.append("caseSensitiveResponder")
        }
        if caseInsensitiveResponder != nil {
            responders.append("caseInsensitiveResponder")
        }
        if dynamicCaseSensitiveResponder != nil {
            responders.append("dynamicCaseSensitiveResponder")
        }
        if dynamicCaseInsensitiveResponder != nil {
            responders.append("dynamicCaseInsensitiveResponder")
        }
        let respondersString = "if " + responders.map({
            "try \($0).respond(router: self, socket: socket, request: &request, completionHandler: completionHandler) {"
        }).joined(separator: "\n} else if ") + "\n} else {\nreturn false\n}"
        return try! .init("""
        @inlinable
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
}

// MARK: Respond with static responder decl
extension CompiledRouterStorage {
    private func respondWithStaticResponderDecl() -> FunctionDeclSyntax {
        try! .init("""
        @inlinable
        \(raw: visibility)func respond(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: borrowing some StaticRouteResponderProtocol,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) {
            try responder.respond(router: self, socket: socket, request: &request, completionHandler: completionHandler)
        }
        """)
    }
}

// MARK: Default dynamic response decl
extension CompiledRouterStorage {
    private func defaultDynamicResponseDecl() -> FunctionDeclSyntax {
        try! .init("""
        @inlinable
        \(raw: visibility)func defaultDynamicResponse(
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: some DynamicRouteResponderProtocol
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
    private func respondWithDynamicResponderDecl() -> FunctionDeclSyntax {
        try! .init("""
        @inlinable
        \(raw: visibility)func respond(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            responder: some DynamicRouteResponderProtocol,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) {
            var response = try defaultDynamicResponse(request: &request, responder: responder)
            do throws(MiddlewareError) {
                try handleDynamicMiddleware(for: &request, with: &response)
            } catch {
                throw .middlewareError(error)
            }
            try responder.respond(router: self, socket: socket, request: &request, response: &response, completionHandler: completionHandler)
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
        return try! .init("""
        @inlinable
        \(raw: visibility)func respondWithNotFound(
            socket: some FileDescriptor,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            \(raw: responder ?? "return false")
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
        return try! .init("""
        @inlinable
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
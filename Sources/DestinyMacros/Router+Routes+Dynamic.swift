
#if NonEmbedded

import DestinyBlueprint
import DestinyDefaults
import DestinyDefaultsNonEmbedded
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Dynamic responses string
extension RouterStorage {
    mutating func dynamicRoutesResponder(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool
    ) -> CompiledRouterStorage.Responder? {
        let getRouteStartLine:(DynamicRoute) -> String
        let routes:[(DynamicRoute, FunctionCallExprSyntax)]
        if isCaseSensitive {
            getRouteStartLine = { $0.startLine() }
            routes = dynamicRouteStorage.caseSensitiveRoutes
        } else {
            getRouteStartLine = { $0.startLine().lowercased() }
            routes = dynamicRouteStorage.caseInsensitiveRoutes
        }
        let copyable:String?
        let noncopyable:String?
        if let responders = dynamicRoutesSyntax(
            context: context,
            isCopyable: true,
            getRouteStartLine: getRouteStartLine,
            routes: routes
        ) {
            copyable = responderStorageDecl(isCaseSensitive: isCaseSensitive, isCopyable: true, responders: responders).name.text + "()"
        } else {
            copyable = nil
        }
        if let responders = dynamicRoutesSyntax(
            context: context,
            isCopyable: false,
            getRouteStartLine: getRouteStartLine,
            routes: routes
        ) {
            noncopyable = responderStorageDecl(isCaseSensitive: isCaseSensitive, isCopyable: false, responders: responders).name.text + "()"
        } else {
            noncopyable = nil
        }
        return .get(copyable, noncopyable)
    }
}

extension RouterStorage {
    private mutating func dynamicRoutesSyntax(
        context: some MacroExpansionContext,
        isCopyable: Bool,
        getRouteStartLine: (DynamicRoute) -> String,
        routes: [(DynamicRoute, FunctionCallExprSyntax)],
    ) -> [(path: SIMD64<UInt8>, responder: String)]? {
        guard !routes.isEmpty else { return nil }
        var responders = [(path: SIMD64<UInt8>, responder: String)]()
        var parameterized = [(DynamicRoute, FunctionCallExprSyntax)]()
        var parameterless = [(DynamicRoute, FunctionCallExprSyntax)]()
        var catchall = [(DynamicRoute, FunctionCallExprSyntax)]()
        for route in routes {
            if route.0.path.firstIndex(where: { $0.isParameter }) != nil {
                if route.0.path.firstIndex(where: { $0 == .catchall }) != nil {
                    catchall.append(route)
                } else {
                    parameterized.append(route)
                }
            } else {
                parameterless.append(route)
            }
        }
        for (route, function) in parameterless {
            let string = getRouteStartLine(route)
            let buffer = SIMD64<UInt8>(string)
            guard let literalResponder = dynamicResponderValue(
                route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription(useGenerics: settings.dynamicResponsesAreGeneric)),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(string) else {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                continue
            }
            registeredPaths.insert(string)
            responders.append((buffer, literalResponder))
        }
        for (route, function) in parameterized {
            var string = "\(route.method.rawNameString()) /\(route.path.map({ $0.isParameter ? ":any" : $0.slug }).joined(separator: "/")) \(route.version.string)"
            let pathLiteral = string
            string = getRouteStartLine(route)
            let buffer = SIMD64<UInt8>(pathLiteral)
            guard let literalResponder = dynamicResponderValue(
                route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription(useGenerics: settings.dynamicResponsesAreGeneric)),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(string) else {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                continue
            }
            registeredPaths.insert(string)
            responders.append((buffer, literalResponder))
        }
        for (route, function) in catchall {
            let string = getRouteStartLine(route)
            let buffer = SIMD64<UInt8>(string)
            guard let literalResponder = dynamicResponderValue(
                route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription(useGenerics: settings.dynamicResponsesAreGeneric)),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(string) else {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                continue
            }
            registeredPaths.insert(string)
            responders.append((buffer, literalResponder))
        }
        return responders.isEmpty ? nil : responders
    }
    
    mutating func dynamicResponderValue(
        route: RouterStorage.Route,
        isCopyable: Bool
    ) -> String? {
        var responder = route.responder
        var isAsync = responder.contains(" await ")
        let logicSplit = responder.split(separator: "logic: {")
        guard let responderBody = logicSplit.getPositive(1), let parameters = responderBody.firstIndex(of: "\n") else {
            guard isCopyable == isAsync else { return nil }
            return responder
        }
        var responderBodyArguments = responderBody[responderBody.index(after: parameters)...]
        while responderBodyArguments.last != "}" {
            responderBodyArguments.removeLast()
        }
        responderBodyArguments.removeLast()
        responder = String(responderBodyArguments)

        var dynamicResponseTypeAnnotation:Substring = "DynamicResponse"
        var defaultResponse:Substring = "DynamicResponse()"
        let defaultResponseSplit = logicSplit.getPositive(0)?.split(separator: "defaultResponse:")
        if var defaultResponseArgument = defaultResponseSplit?.getPositive(1) {
            while defaultResponseArgument.last != ")" {
                defaultResponseArgument.removeLast()
            }
            defaultResponse = defaultResponseArgument
            dynamicResponseTypeAnnotation = defaultResponse.split(separator: "(")[0]
            //responder = String(defaultResponseSplit!.first!)
        }
        isAsync = responder.contains(" await ")
        guard isCopyable == isAsync else { return nil }

        let name = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)"
        let responderThrows = responder.contains(" try ") || responder.contains(" throw ")
        if responderThrows {
            responder = """
            do {
                \(responder)
            } catch {
                let err = ResponderError.custom("\(name)Error;\\(error)")
                if !router.respondWithError(socket: socket, error: err, request: &request, completionHandler: completionHandler) {
                    completionHandler()
                }
                return
            }
            """
        }
        while responder.first?.isWhitespace ?? false {
            responder.removeFirst()
        }
        while responder.last?.isWhitespace ?? false {
            responder.removeLast()
        }
        let paths = route.paths.map({ PathComponent.init(stringLiteral: String($0)) })
        var members = MemberBlockItemListSyntax()
        members.append(DeclSyntax.init(stringLiteral: "let _defaultResponse = \(defaultResponse)"))
        members.append(DeclSyntax.init(stringLiteral: """
        \(inlinableAnnotation)
        \(inlineAlwaysAnnotation)
        \(visibility)var pathComponentsCount: Int {
            \(paths.count)
        }
        """))

        let pathComponentAtIndexValues = """
        switch index {
        \((0..<paths.count).map({ "case \($0): \(paths[$0].debugDescription)" }).joined(separator: "\n"))
        default: fatalError("out-of-bounds")
        }
        """
        members.append(DeclSyntax.init(stringLiteral: """
        \(inlinableAnnotation)
        \(inlineAlwaysAnnotation)
        \(visibility)func pathComponent(at index: Int) -> PathComponent {
            \(pathComponentAtIndexValues)
        }
        """))

        var yieldPathComponentParameters = ""
        for (index, path) in paths.enumerated() {
            if path.isParameter {
                yieldPathComponentParameters += "yield(\(index))\n"
            }
        }
        members.append(DeclSyntax.init(stringLiteral: """
        \(inlinableAnnotation)
        \(inlineAlwaysAnnotation)
        \(visibility)func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
            \(yieldPathComponentParameters)
        }
        """))
        members.append(DeclSyntax.init(stringLiteral: """
        \(inlinableAnnotation)
        \(inlineAlwaysAnnotation)
        \(visibility)func defaultResponse() -> \(dynamicResponseTypeAnnotation) {
            _defaultResponse
        }
        """))
        
        let asyncTaskValues:(setup: String, suffix: String)
        if isAsync {
            asyncTaskValues = ("var request = request.copy()\nvar response = response\nTask {\n", "\n}")
        } else {
            asyncTaskValues = ("", "")
        }
        members.append(DeclSyntax.init(stringLiteral: """
        \(inlinableAnnotation)
        \(visibility)func respond(
            router: \(routerParameter(isCopyable: isCopyable, protocolConformances: settings.hasProtocolConformances)),
            socket: some FileDescriptor,
            request: \(requestTypeSyntax),
            response: inout some DynamicResponseProtocol,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) {
            \(asyncTaskValues.setup)
            \(responder)
            do throws(SocketError) {
                try response.write(to: socket)
            } catch {
                let err = ResponderError.socketError(error)
                if !router.respondWithError(socket: socket, error: err, request: &request, completionHandler: completionHandler) {
                    completionHandler()
                }
                return
            }
            completionHandler()\(asyncTaskValues.suffix)
        }
        """))
        let compilationCondition = isCopyable ? "Copyable" : "NonCopyable"
        let structure = StructDeclSyntax(
            leadingTrivia: "#if \(compilationCondition)\n// MARK: \(name)\n",
            modifiers: [visibilityModifier],
            name: .init(stringLiteral: name),
            inheritanceClause: .init(
                inheritedTypes: dynamicRouteResponderProtocolConformances(isCopyable: isCopyable, protocolConformance: settings.hasProtocolConformances)
            ),
            memberBlock: .init(members: members),
            trailingTrivia: "\n#endif"
        )
        generatedDecls.append(structure)
        responder = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)()"
        autoGeneratedDynamicRespondersIndex += 1
        return responder
    }
}

// MARK: Responder storage decl
extension RouterStorage {
    private mutating func responderStorageDecl(
        isCaseSensitive: Bool,
        isCopyable: Bool,
        responders: [(path: SIMD64<UInt8>, responder: String)]
    ) -> StructDeclSyntax {
        let routerParameter = routerParameter(isCopyable: isCopyable, protocolConformances: settings.hasProtocolConformances)
        var responderMembers = MemberBlockItemListSyntax()
        var entryMembers = MemberBlockItemListSyntax()
        entryMembers.append(VariableDeclSyntax(leadingTrivia: "\n", .let, name: "path", type: .init(type: TypeSyntax("SIMD64<UInt8>"))))
        entryMembers.append(VariableDeclSyntax(leadingTrivia: "\n", .let, name: "responder", type: .init(type: TypeSyntax("ConcreteResponder"))))
        for (index, (path, responder)) in responders.enumerated() {
            responderMembers.append(VariableDeclSyntax.init(
                modifiers: [visibilityModifier],
                .let,
                name: "route\(raw: index)",
                initializer: .init(value: ExprSyntax(stringLiteral: "Entry(path: \(path), responder: \(responder))"))
            ))
        }
        let respondedDecl = try! FunctionDeclSyntax("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func responded(
            router: \(raw: routerParameter),
            socket: some FileDescriptor,
            request: \(requestTypeSyntax),
            requestPathCount: Int,
            requestStartLine: SIMD64<UInt8>,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            if path == requestStartLine { // parameterless
                try router.respond(socket: socket, request: &request, responder: responder, completionHandler: completionHandler)
                return true
            } else { // parameterized and catchall
                let pathComponentsCount = responder.pathComponentsCount
                var found = true
                var lastIsCatchall = false
                var lastIsParameter = false
                loop: for i in 0..<pathComponentsCount {
                    let path = responder.pathComponent(at: i)
                    switch path {
                    case .catchall:
                        lastIsCatchall = true
                        lastIsParameter = false
                        break loop
                    case .literal(let l):
                        lastIsCatchall = false
                        lastIsParameter = false
                        if requestPathCount <= i {
                            found = false
                            break loop
                        } else {
                            do throws(SocketError) {
                                let pathAtIndex = try request.path(at: i)
                                if l != pathAtIndex {
                                    found = false
                                    break loop
                                }
                            } catch {
                                throw .socketError(error)
                            }
                        }
                    case .parameter:
                        lastIsCatchall = false
                        lastIsParameter = true
                    default: // TODO: fixme
                        found = false
                        break loop
                    }
                }
                if found && (lastIsCatchall || lastIsParameter && requestPathCount == pathComponentsCount) {
                    try router.respond(socket: socket, request: &request, responder: responder, completionHandler: completionHandler)
                    return true
                }
                return false
            }
        }
        """)
        entryMembers.append(respondedDecl)

        let (copyableSymbol, copyableText) = responderCopyableValues(isCopyable: isCopyable)
        let entryDecl = StructDeclSyntax(
            modifiers: [visibilityModifier],
            name: "Entry",
            genericParameterClause: .init(parameters: .init([
                .init(name: "ConcreteResponder", colon: ":", inheritedType: TypeSyntax("\(raw: copyableText)DynamicRouteResponderProtocol\(raw: isCopyable ? "" : " & ~Copyable")"))
            ])),
            inheritanceClause: .init(inheritedTypes: .init([
                .init(type: TypeSyntax("\(raw: copyableSymbol)Copyable"))
            ])),
            memberBlock: .init(members: entryMembers)
        )
        responderMembers.append(entryDecl)

        var respondersString = responders.enumerated().map({ index, _ in
            "if try route\(index).responded(router: router, socket: socket, request: &request, requestPathCount: requestPathCount, requestStartLine: requestStartLine, completionHandler: completionHandler) {\nreturn true\n"
        }).joined(separator: "} else ")
        if !responders.isEmpty {
            respondersString += "}"
        }
        let respondDecl = try! FunctionDeclSyntax("""
        \(raw: inlinableAnnotation)
        \(raw: visibility)func respond(
            router: \(raw: routerParameter),
            socket: some FileDescriptor,
            request: \(requestTypeSyntax),
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            let requestPathCount:Int
            let requestStartLine:SIMD64<UInt8>
            do throws(SocketError) {
                requestPathCount = try request.pathCount()
                requestStartLine = try request.startLine()
            } catch {
                throw .socketError(error)
            }
            \(raw: respondersString)
            return false
        }
        """)
        responderMembers.append(respondDecl)

        let name:String
        if isCaseSensitive {
            name = "CaseSensitiveResponderStorage\(autoGeneratedCaseSensitiveRespondersIndex)"
        } else {
            name = "CaseInsensitiveResponderStorage\(autoGeneratedCaseInsensitiveRespondersIndex)"
        }
        let compilationCondition = copyableText.isEmpty ? "Copyable" : "NonCopyable"
        let responderDecl = StructDeclSyntax.init(
            leadingTrivia: "#if \(compilationCondition)\n// MARK: \(name)\n",
            modifiers: [visibilityModifier],
            name: "\(raw: name)",
            inheritanceClause: .init(
                inheritedTypes: responderStorageProtocolConformances(isCopyable: isCopyable, protocolConformance: settings.hasProtocolConformances)
            ),
            memberBlock: .init(members: responderMembers),
            trailingTrivia: "\n#endif"
        )
        generatedDecls.append(responderDecl)
        if isCaseSensitive {
            autoGeneratedCaseSensitiveRespondersIndex += 1
        } else {
            autoGeneratedCaseInsensitiveRespondersIndex += 1
        }
        return responderDecl
    }
}

// MARK: Append routes
extension RouterStorage {
    mutating func appendDynamicRoutes(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        isCopyable: Bool,
        routes: [(DynamicRoute, FunctionCallExprSyntax)],
        literalRoutePaths: inout [String],
        routeResponders: inout [String]
    ) {
        let routeStartLine:(DynamicRoute) -> String = isCaseSensitive ? { $0.startLine() } : { $0.startLine().lowercased() }
        for (route, function) in routes {
            guard route.path.firstIndex(where: { !$0.isLiteral }) == nil else {
                continue
            }
            let startLine = routeStartLine(route)
            guard let responder = dynamicResponderValue(
                route: .init(startLine: startLine, buffer: .init(startLine), responder: route.responderDebugDescription(useGenerics: settings.dynamicResponsesAreGeneric)),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(startLine) else {
                Router.routePathAlreadyRegistered(context: context, node: function, startLine)
                continue
            }

            registeredPaths.insert(startLine)
            literalRoutePaths.append(route.startLine())
            routeResponders.append(responder)
            dynamicRouteStorage.remove(isCaseSensitive: isCaseSensitive, path: route.path, function: function)
        }
    }
}

#endif

import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension RouterStorage {
    mutating func dynamicRoutesSyntax(
        mutable: Bool,
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        isCopyable: Bool,
        routes: [(DynamicRoute, FunctionCallExprSyntax)]
    ) -> [(path: SIMD64<UInt8>, responder: String)]? {
        guard !routes.isEmpty else { return nil }
        var literalResponders = [(path: SIMD64<UInt8>, responder: String)]()
        let getRouteStartLine:(DynamicRoute) -> String = isCaseSensitive ? { $0.startLine() } : { $0.startLine().lowercased() }
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
            guard let literalResponder = getResponderValue(
                route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(string) else {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                continue
            }
            registeredPaths.insert(string)
            literalResponders.append((buffer, literalResponder))
        }
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                var string = "\(route.method.rawNameString()) /\(route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/")) \(route.version.string)"
                let pathLiteral = string
                string = getRouteStartLine(route)
                let buffer = SIMD64<UInt8>(pathLiteral)
                guard let literalResponder = getResponderValue(
                    route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription),
                    isCopyable: isCopyable
                ) else { continue }
                guard !registeredPaths.contains(string) else {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                    continue
                }
                registeredPaths.insert(string)
                literalResponders.append((buffer, literalResponder))
            }
        }
        for (route, function) in catchall {
            let string = getRouteStartLine(route)
            let buffer = SIMD64<UInt8>(string)
            guard let literalResponder = getResponderValue(
                route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription),
                isCopyable: isCopyable
            ) else { continue }
            guard !registeredPaths.contains(string) else {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                continue
            }
            registeredPaths.insert(string)
            literalResponders.append((buffer, literalResponder))
        }
        return literalResponders.isEmpty ? nil : literalResponders
    }
    
    mutating func getResponderValue(
        route: RouterStorage.Route,
        isCopyable: Bool
    ) -> String? {
        var responder = route.responder
        var isAsync = responder.contains(" await ")
        let logicSplit = responder.split(separator: "logic: {")
        if let responderBody = logicSplit.getPositive(1), let parameters = responderBody.firstIndex(of: "\n") {
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

            let name = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)"
            let paths = route.paths
            let parameterPathIndexes = paths.enumerated().compactMap({ $0.element.first == ":" || $0.element.first == "*" ? $0.offset : nil })

            isAsync = responder.contains(" await ")
            guard isCopyable == isAsync else { return nil }
            let responderThrows = responder.contains(" try ") || responder.contains(" throw ")
            if responderThrows {
                responder = """
                do {
                    \(responder)
                } catch {
                    let err = ResponderError(identifier: "\(name)Error", reason: "\\(error)")
                    if !router.respondWithError(socket: socket, error: err, request: &request, completionHandler: completionHandler) {
                        completionHandler()
                    }
                    return
                }
                """
            }

            var memberBlock = MemberBlockSyntax(members: .init())
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "let path:InlineArray<\(paths.count), PathComponent> = \(paths)")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "let _defaultResponse = \(defaultResponse)")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\n\(visibility)var pathComponentsCount: Int { \(paths.count) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\n\(visibility)func pathComponent(at index: Int) -> PathComponent { path[index] }")))
            
            let yieldPathComponentParameters = parameterPathIndexes.isEmpty ? "" : "\n" + parameterPathIndexes.map({ "yield(\($0))" }).joined(separator: "\n")
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\n\(visibility)func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {\(yieldPathComponentParameters) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\n\(visibility)func defaultResponse() -> \(dynamicResponseTypeAnnotation) { _defaultResponse }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: """
            \(inlinableAnnotation)
            \(visibility)func respond(
                router: \(routerParameter(isCopyable: isCopyable)),
                socket: some FileDescriptor,
                request: inout some HTTPRequestProtocol & ~Copyable,
                response: inout some DynamicResponseProtocol,
                completionHandler: @Sendable @escaping () -> Void
            ) throws(ResponderError) {
                \(isAsync ? "var request = request.copy()\nvar response = response\nTask {\n" : "")
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
                completionHandler()\(isAsync ? "\n}" : "")
            }
            """)))
            let structure = StructDeclSyntax(
                leadingTrivia: .init(stringLiteral: "// MARK: \(name)\n\(visibility)"),
                name: .init(stringLiteral: name),
                inheritanceClause: .init(inheritedTypes: .init(arrayLiteral:
                    .init(type: TypeSyntax(stringLiteral: "\(isCopyable ? "" : "NonCopyable")DynamicRouteResponderProtocol"), trailingComma: ","),
                    .init(type: TypeSyntax(stringLiteral: "\(isCopyable ? "" : "~")Copyable"))
                )),
                memberBlock: memberBlock
            )
            generatedDecls.append(structure)
            responder = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)()"
            autoGeneratedDynamicRespondersIndex += 1
        } else {
            guard isCopyable == isAsync else { return nil }
        }
        return responder
    }
}
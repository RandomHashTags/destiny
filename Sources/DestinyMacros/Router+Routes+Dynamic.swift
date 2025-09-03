
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension RouterStorage {
    mutating func dynamicRoutesSyntax(
        mutable: Bool,
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
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
        let parameterlessString = parameterless.isEmpty ? "" : parameterless.compactMap({ route, function in
            let string = getRouteStartLine(route)
            if registeredPaths.contains(string) {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                return nil
            } else {
                registeredPaths.insert(string)
                let buffer = SIMD64<UInt8>(string)
                let (literalResponder, responder) = getResponderValue(
                    route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription)
                )
                literalResponders.append((buffer, literalResponder))
                return "// \(string)\n\(responder)"
            }
        }).joined(separator: ",\n\n") + "\n"
        var parameterizedByPathCount = [String]()
        var parameterizedString = ""
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                if parameterizedByPathCount.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterizedByPathCount.count) {
                        parameterizedByPathCount.append("")
                    }
                }
                var string = "\(route.method.rawNameString()) /\(route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/")) \(route.version.string)"
                if !registeredPaths.contains(string) {
                    registeredPaths.insert(string)
                    string = getRouteStartLine(route)
                    let buffer = SIMD64<UInt8>(string)
                    let (literalResponder, responder) = getResponderValue(
                        route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription)
                    )
                    literalResponders.append((buffer, literalResponder))
                    parameterizedByPathCount[route.path.count].append("\n// \(string)\n\(responder)")
                } else {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                }
            }
            parameterizedString += "\n" + parameterizedByPathCount.compactMap({ $0.isEmpty ? nil : $0 }).joined(separator: ",\n") + "\n"
        }
        let catchallString = catchall.isEmpty ? "" : catchall.compactMap({ route, function in
            let string = getRouteStartLine(route)
            if registeredPaths.contains(string) {
                Router.routePathAlreadyRegistered(context: context, node: function, string)
                return nil
            } else {
                registeredPaths.insert(string)
                let buffer = SIMD64<UInt8>(string)
                let (literalResponder, responder) = getResponderValue(
                    route: .init(startLine: string, buffer: buffer, responder: route.responderDebugDescription)
                )
                literalResponders.append((buffer, literalResponder))
                return "// \(string)\n\(responder)"
            }
        }).joined(separator: ",\n\n") + "\n"
        return literalResponders
    }

    mutating func getResponderValue(
        route: RouterStorage.Route
    ) -> (responder: String, responderValue: String) {
        var responder = route.responder
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

            let isAsync = responder.contains(" await ")
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
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\(visibility)var pathComponentsCount: Int { \(paths.count) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\(visibility)func pathComponent(at index: Int) -> PathComponent { path[index] }")))
            
            let yieldPathComponentParameters = parameterPathIndexes.isEmpty ? "" : "\n" + parameterPathIndexes.map({ "yield(\($0))" }).joined(separator: "\n")
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\(visibility)func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {\(yieldPathComponentParameters) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "\(inlinableAnnotation)\(visibility)func defaultResponse() -> \(dynamicResponseTypeAnnotation) { _defaultResponse }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: """
            \(inlinableAnnotation)
            \(visibility)func respond(
                router: \(routerParameter),
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
                    .init(type: TypeSyntax(stringLiteral: "\(settings.isCopyable ? "" : "NonCopyable")DynamicRouteResponderProtocol"), trailingComma: ","),
                    .init(type: TypeSyntax(stringLiteral: "\(settings.isCopyable ? "" : "~")Copyable"))
                )),
                memberBlock: memberBlock
            )
            generatedDecls.append(structure)
            responder = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)()"
            autoGeneratedDynamicRespondersIndex += 1
        }
        return (responder, "CompiledDynamicResponderStorageRoute(\npath: \(route.buffer),\nresponder: \(responder)\n)")
    }
}
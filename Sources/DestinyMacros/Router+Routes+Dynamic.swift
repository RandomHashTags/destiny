
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
    ) -> String {
        let typeAnnotation = "\(mutable ? "" : "Compiled")DynamicResponderStorage"
        guard !routes.isEmpty else {
            if mutable {
                return "\(typeAnnotation)()" 
            } else {
                return "\(typeAnnotation)(())"
            }
        }
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
                let responder = getResponderValue(
                    route: .init(startLine: string, buffer: .init(string), responder: route.responderDebugDescription)
                )
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
                    let responder = getResponderValue(
                        route: .init(startLine: string, buffer: .init(string), responder: route.responderDebugDescription)
                    )
                    parameterizedByPathCount[route.path.count].append("\n// \(string)\n" + responder)
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
                let responder = getResponderValue(
                    route: .init(startLine: string, buffer: .init(string), responder: route.responderDebugDescription)
                )
                return "// \(string)\n\(responder)"
            }
        }).joined(separator: ",\n\n") + "\n"
        var string = "\(typeAnnotation)(\n"
        if !mutable {
            string += "(\n"
        }
        string += parameterlessString + (parameterlessString.isEmpty ? "" : ",\n")
        string += parameterizedString + (parameterizedString.isEmpty ? "" : ",\n")
        string += catchallString
        if !mutable {
            string += "\n)"
        }
        return string + "\n)"
    }

    mutating func getResponderValue(
        route: RouterStorage.Route
    ) -> String {
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
                    err = ResponderError(identifier: "\(name)Error", reason: "\\(error)")
                }
                """
            }

            var memberBlock = MemberBlockSyntax(members: MemberBlockItemListSyntax())
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "let path:InlineArray<\(paths.count), PathComponent> = \(paths)")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "let _defaultResponse = \(defaultResponse)")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "@inlinable var pathComponentsCount: Int { \(paths.count) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "@inlinable func pathComponent(at index: Int) -> PathComponent { path[index] }")))
            
            let yieldPathComponentParameters = parameterPathIndexes.isEmpty ? "" : "\n" + parameterPathIndexes.map({ "yield(\($0))" }).joined(separator: "\n")
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "@inlinable func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {\(yieldPathComponentParameters) }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: "@inlinable func defaultResponse() -> \(dynamicResponseTypeAnnotation) { _defaultResponse }")))
            memberBlock.members.append(.init(decl: DeclSyntax.init(stringLiteral: """
            @inlinable
            func respond(
                router: some HTTPRouterProtocol,
                socket: Int32,
                request: inout some HTTPRequestProtocol & ~Copyable,
                response: inout some DynamicResponseProtocol
            ) throws(ResponderError) {
                \(isAsync ? "var request = request.copy()\nvar response = response\nTask {\n" : "")var err:ResponderError? = nil
                \(responder)
                if let err {
                    if !router.respondWithError(socket: socket, error: err, request: &request, logger: Logger(label: "\(name).destiny")) { // TODO: fix logger
                        socket.socketClose()
                    }
                    return
                }
                do throws(SocketError) {
                    try response.write(to: socket)
                } catch {
                    err = .socketError(error)
                }
                socket.socketClose()
                if let err {
                    if !router.respondWithError(socket: socket, error: err, request: &request, logger: Logger(label: "\(name).destiny")) { // TODO: fix logger
                        socket.socketClose()
                    }
                    return
                }\(isAsync ? "\n}" : "")
            }
            """)))
            let structure = StructDeclSyntax(
                leadingTrivia: .init(stringLiteral: "// MARK: \(name)\n"),
                name: .init(stringLiteral: name),
                inheritanceClause: .init(inheritedTypes: .init(arrayLiteral: .init(type: TypeSyntax(stringLiteral: "DynamicRouteResponderProtocol")))),
                memberBlock: memberBlock
            )
            autoGeneratedStructs.append(structure)
            responder = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)()"
            autoGeneratedDynamicRespondersIndex += 1
        }
        return "CompiledDynamicResponderStorageRoute(\npath: \(route.buffer),\nresponder: \(responder)\n)"
    }
}
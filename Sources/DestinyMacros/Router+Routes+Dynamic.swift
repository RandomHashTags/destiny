
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension RouterStorage {
    mutating func dynamicRoutesString(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        routes: [(DynamicRoute, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return "CompiledDynamicResponderStorage(())" }
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
        let parameterlessString = parameterless.isEmpty ? "" : "\n" + parameterless.compactMap({ route, function in
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
        let catchallString = catchall.isEmpty ? "" : "\n" + catchall.compactMap({ route, function in
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
        var string = "CompiledDynamicResponderStorage(\n(\n"
        string += parameterlessString + (parameterlessString.isEmpty ? "" : ",\n")
        string += parameterizedString + (parameterizedString.isEmpty ? "" : ",\n")
        string += catchallString
        return string + "\n)\n)"
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
            let autoGenStruct = """
            // MARK: \(name)
            struct \(name): DynamicRouteResponderProtocol {
                let path:InlineArray<\(paths.count), PathComponent> = \(paths)
                let _defaultResponse = \(defaultResponse)

                @inlinable var pathComponentsCount: Int { \(paths.count) }
                @inlinable func pathComponent(at index: Int) -> PathComponent { path[index] }

                @inlinable
                func forEachPathComponentParameterIndex(_ yield: (Int) -> Void) {
                    \(parameterPathIndexes.map({ "yield(\($0))" }).joined(separator: "\n"))
                }

                @inlinable
                func defaultResponse() -> \(dynamicResponseTypeAnnotation) {
                    _defaultResponse
                }

                @inlinable
                func respond(
                    to socket: borrowing some HTTPSocketProtocol & ~Copyable,
                    request: inout some HTTPRequestProtocol & ~Copyable,
                    response: inout some DynamicResponseProtocol
                ) async throws(ResponderError) {
                    \(responder)
                    do throws(SocketError) {
                        try await response.write(to: socket)
                    } catch {
                        throw .socketError(error)
                    }
                }
            }
            """
            try! autoGeneratedStructs.append(StructDeclSyntax(.init(stringLiteral: autoGenStruct)))
            autoGeneratedDynamicResponders.append(autoGenStruct)
            responder = "DynamicResponder\(autoGeneratedDynamicRespondersIndex)()"
            autoGeneratedDynamicRespondersIndex += 1
        }
        return "CompiledDynamicResponderStorageRoute(\npath: \(route.buffer),\nresponder: \(responder)\n)"
    }
}
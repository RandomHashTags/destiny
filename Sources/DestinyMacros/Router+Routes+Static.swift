
import DestinyBlueprint
import DestinyDefaults
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Static routes string
extension RouterStorage {
    mutating func staticRoutesSyntax(
        mutable: Bool,
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        redirects: [(any RedirectionRouteProtocol, SyntaxProtocol)],
        middleware: [CompiledStaticMiddleware],
        routes: [(StaticRoute, FunctionCallExprSyntax)]
    ) -> String {
        let typeAnnotation = "\(mutable ? "" : "Compiled")Case\(isCaseSensitive ? "S" : "Ins")ensitiveStaticResponderStorage"
        guard !routes.isEmpty else {
            if mutable {
                return "\(typeAnnotation)()"
            } else {
                return "\(typeAnnotation)(())"
            }
        }
        var routePaths = [String]()
        var literalRouteResponders = [String]()

        var routeResponders = [String]()
        let getRouteStartLine:(StaticRoute) -> String = isCaseSensitive ? { $0.startLine } : { $0.startLine.lowercased() }
        let getRedirectRouteStartLine:(any RedirectionRouteProtocol) -> String = isCaseSensitive ? { route in
            return route.fromStartLine()
        } : { route in
            return route.fromStartLine().lowercased()
        }
        let getResponderValue:(RouterStorage.Route) -> String = {
            let responder = $0.responder
            return "// \($0.startLine)\nCompiledStaticResponderStorageRoute(\npath: \($0.buffer),\nresponder: \(responder)\n)"
        }
        if !redirects.isEmpty {
            for (route, function) in redirects {
                var string = getRedirectRouteStartLine(route)
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                } else {
                    registeredPaths.insert(string)
                    do throws(AnyError) {
                        let responder = try IntermediateResponseBody(type: .stringWithDateHeader, "").responderDebugDescription(route.response())
                        routeResponders.append(getResponderValue(.init(startLine: string, buffer: .init(&string), responder: responder)))
                    } catch {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRedirectError", message: "\(error)")))
                    }
                }
            }
        }
        for (route, function) in routes {
            do throws(HTTPMessageError) {
                var string = getRouteStartLine(route)
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                } else {
                    registeredPaths.insert(string)
                    let buffer = DestinyRoutePathType(&string)
                    let httpResponse = route.response(context: context, function: function, middleware: middleware) as! HTTPResponseMessage // TODO: fix
                    if true /*route.supportedCompressionAlgorithms.isEmpty*/ {
                        if let responder = try responseBodyResponderDebugDescription(body: route.body, response: httpResponse) {
                            routePaths.append("\(string)")
                            literalRouteResponders.append(responder)
                            routeResponders.append(getResponderValue(.init(startLine: string, buffer: buffer, responder: responder)))
                        } else {
                            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "failedToGetResponderDebugDescriptionForResponseBody", message: "Failed to get responder debug description for response body; body=\(String(describing: route.body));function=\(function.debugDescription)", severity: .warning)))
                        }
                    } else if let httpResponse = httpResponse as? HTTPResponseMessage {
                        Router.conditionalRoute(
                            context: context,
                            conditionalResponders: &conditionalResponders,
                            route: route,
                            function: function,
                            string: string,
                            buffer: buffer,
                            httpResponse: httpResponse
                        )
                    } else {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "unexpectedHTTPResponseMessage", message: "Router.Storage;staticRoutesSyntax;conditionalRoute;httpResponse variable is not a HTTPResponseMessage")))
                    }
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
            }
        }

        let random = UInt16.random(in: 0..<UInt16.max)
        var enumDecl = StructDeclSyntax(
            leadingTrivia: "// MARK: OptimalStaticRouteResponder\(random)\n",
            name: "OptimalStaticRouteResponder\(raw: random)",
            inheritanceClause: .init(
                inheritedTypes: .init(arrayLiteral:
                    .init(type: TypeSyntax.init(stringLiteral: "StaticResponderStorageProtocol"), trailingComma: ","),
                    .init(type: TypeSyntax.init(stringLiteral: "Copyable"))
                )
            ),
            memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax())
        )

        //doHashing(context: context, routePaths: routePaths, enumDecl: &enumDecl, literalRouteResponders: literalRouteResponders)
        staticConstants(context: context, routePaths: routePaths, enumDecl: &enumDecl, literalRouteResponders: literalRouteResponders)

        generatedDecls.append(enumDecl)

        var string = "\(typeAnnotation)(\n"
        /*if !mutable {
            string += "(\n"
        }
        for value in routeResponders {
            string += value + ",\n"
        }
        if !routeResponders.isEmpty { // was modified
            string.removeLast(2)
        }
        if !mutable {
            string += "\n)"
        }*/
        return enumDecl.name.text + "()"
        return string + "\n)"
    }
    private func responseBodyResponderDebugDescription(
        body: (any ResponseBodyProtocol)?,
        response: HTTPResponseMessage
    ) throws(HTTPMessageError) -> String? {
        guard let body else { return nil }
        let s:String?
        if let v = body as? String {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? IntermediateResponseBody {
            s = v.responderDebugDescription(response)

        } else {
            s = nil
        }
        return s
    }
}

// MARK: Static constants
extension RouterStorage {
    private func staticConstants(
        context: some MacroExpansionContext,
        routePaths: [String],
        enumDecl: inout StructDeclSyntax,
        literalRouteResponders: [String]
    ) {
        let routePathSIMDs:[SIMD64<UInt8>] = routePaths.compactMap({
            let utf8 = $0.utf8
            var simd = SIMD64<UInt8>.zero
            guard utf8.count > 0 else { return nil }
            for i in 0..<min(simd.scalarCount, utf8.count) {
                simd[i] = utf8[utf8.index(utf8.startIndex, offsetBy: i)]
            }
            return simd
        })
        let routePathCaseNames = routePaths.map({ "`\($0)`" })

        var staticResponders = [VariableDeclSyntax]()
        var staticSIMDs = [VariableDeclSyntax]()
        for index in 0..<routePaths.count {
            let staticResponder = try! VariableDeclSyntax.init("""
            static let responder\(raw: index) = \(raw: literalRouteResponders[index])
            """)
            staticResponders.append(staticResponder)

            let staticSIMD = try! VariableDeclSyntax.init("""
            static let simd\(raw: index) = \(raw: routePathSIMDs[index])
            """)
            staticSIMDs.append(staticSIMD)
        }
        enumDecl.memberBlock.members.append(contentsOf: staticSIMDs.map({ MemberBlockItemSyntax.init(decl: $0) }))

        let routeResponderDecl = try! FunctionDeclSyntax.init("""
        @inlinable
        func respond(
            router: some HTTPRouterProtocol,
            socket: Int32,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(SocketError) -> Bool {
            switch self {
            \(raw: routePathCaseNames.enumerated().map({ "case .\($0.element):\ntry Self.responder\($0.offset).respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)" }).joined(separator: "\n"))
            }
            return true
        }
        """)
        var routeConstantsDecl = try! EnumDeclSyntax.init("""
        enum StaticRoute {
        }
        """)
        for caseName in routePathCaseNames {
            routeConstantsDecl.memberBlock.members.append(.init(decl: try! EnumCaseDeclSyntax.init("case \(raw: caseName)")))
        }
        routeConstantsDecl.memberBlock.members.append(.init(decl: routeResponderDecl))
        routeConstantsDecl.memberBlock.members.append(contentsOf: staticResponders.map({ MemberBlockItemSyntax.init(decl: $0) }))
        enumDecl.memberBlock.members.append(.init(decl: routeConstantsDecl))

        let matchRouteDecl = try! FunctionDeclSyntax.init("""
        @inlinable
        func matchRoute(_ simd: SIMD64<UInt8>) -> StaticRoute? {
            switch simd {
            \(raw: (0..<routePaths.count).map({ "case Self.simd\($0): .`\(routePaths[$0])`" }).joined(separator: "\n"))
            default: nil
            }
        }
        """)
        enumDecl.memberBlock.members.append(.init(decl: matchRouteDecl))

        let responderDecl = try! FunctionDeclSyntax.init("""
        @inlinable
        func respond(
            router: some HTTPRouterProtocol,
            socket: Int32,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            guard let route = matchRoute(request.startLine) else { return false }
            do throws(SocketError) {
                return try route.respond(router: router, socket: socket, request: &request, completionHandler: completionHandler)
            } catch {
                throw .socketError(error)
            }
        }
        """)
        enumDecl.memberBlock.members.append(.init(decl: responderDecl))
    }
}

// MARK: Hashing
extension RouterStorage {
    private func doHashing(
        context: some MacroExpansionContext,
        routePaths: [String],
        enumDecl: inout StructDeclSyntax,
        literalRouteResponders: [String]
    ) {
        let routePathSIMDs:[SIMD64<UInt8>] = routePaths.compactMap({
            let utf8 = $0.utf8
            var simd = SIMD64<UInt8>.zero
            guard utf8.count > 0 else { return nil }
            for i in 0..<min(simd.scalarCount, utf8.count) {
                simd[i] = utf8[utf8.index(utf8.startIndex, offsetBy: i)]
            }
            return simd
        })

        let hashBytes = 4
        if !routePathSIMDs.isEmpty, let positions = findPerfectHashPositions(context: context, routes: routePathSIMDs, maxBytes: hashBytes) {
            let hashTableCount = routePathSIMDs.count * 4
            var alreadyAssigned = [String](repeating: "nil", count: hashTableCount)
            var table = ContiguousArray<UInt16?>(repeating: nil, count: hashTableCount)
            var tableResponders = ContiguousArray<String>(repeating: "nil", count: hashTableCount)
            for (routePathSIMDIndex, route) in routePathSIMDs.enumerated() {
                let bytes = positions.map {
                    let v = UInt8(route[$0])
                    return v == 0 ? .max : v
                }
                let h = mix(bytes)
                let index = Int(h % UInt32(hashTableCount))
                if table[index] != nil { // collision
                    context.diagnose(DiagnosticMsg.unhandled(node: enumDecl, notes: "collision for route: \"\(route.stringSIMD())\" and \"\(alreadyAssigned[index])\""))
                } else {
                    table[index] = UInt16(routePathSIMDIndex)
                    tableResponders[index] = literalRouteResponders[routePathSIMDIndex]
                    alreadyAssigned[index] = routePaths[routePathSIMDIndex]
                }
            }

            let test = VariableDeclSyntax.init(
                modifiers: .init(arrayLiteral: DeclModifierSyntax.init(name: "static")),
                .let,
                name: "table",
                type: .init(type: TypeSyntax.init(stringLiteral: "InlineArray<\(table.count), UInt8?>")),
                initializer: .init(leadingTrivia: " ", value: ExprSyntax.init(stringLiteral: "\(table)"))
            )
            enumDecl.memberBlock.members.append(.init(decl: test))

            for (offset, v) in table.enumerated() {
                if let v {
                    let test = DeclSyntax(stringLiteral: "static let _\(v) = \(tableResponders[offset])")
                    enumDecl.memberBlock.members.append(.init(decl: test))
                }
            }

            let positionsString = positions.map({ "x = (x &* 31) ^ UInt16(simd[\($0)])" }).joined(separator: "\n")
            let perfectHashDecl = try! FunctionDeclSyntax.init("""
            @inlinable
            func perfectHash(
                _ simd: SIMD64<UInt8>
            ) -> UInt16 {
                var x: UInt16 = 0
                \(raw: positionsString)
                return UInt16(x % \(raw: hashTableCount))
            }
            """)
            enumDecl.memberBlock.members.append(.init(decl: perfectHashDecl))

            let responderDecl = try! FunctionDeclSyntax.init("""
            @inlinable
            func respond(
                router: some HTTPRouterProtocol,
                socket: Int32,
                request: inout some HTTPRequestProtocol & ~Copyable,
                completionHandler: @Sendable @escaping () -> Void
            ) throws(ResponderError) -> Bool {
                let hashIndex = Int(perfectHash(request.startLine))
                guard let index = Self.table[hashIndex] else { return false }
                return true
            }
            """)
            enumDecl.memberBlock.members.append(.init(decl: responderDecl))
        } else {
            context.diagnose(DiagnosticMsg.unhandled(node: enumDecl, notes: "couldn't find perfect hash positions with \(hashBytes) bytes"))
        }
    }
    private func mix(_ bytes: [UInt8]) -> UInt32 {
        var x: UInt32 = 2166136261  // FNV offset basis
        for b in bytes {
            x = (x ^ UInt32(b)) &* 16777619 // FNV prime
        }
        return x
    }

    // Attempt to find a set of byte positions that yield a perfect hash
    private func findPerfectHashPositions(
        context: some MacroExpansionContext,
        routes: [SIMD64<UInt8>],
        maxBytes: Int
    ) -> [Int]? {
        var characterCount = Array(repeating: Set<UInt8>(), count: 64)
        for route in routes {
            for i in 0..<route.scalarCount {
                if route[i] != 0 {
                    characterCount[i].insert(route[i])
                }
            }
        }
        var positions:[Int] = []
        var index = -1
        var countAtIndex = 0
        while positions.count < maxBytes {
            for i in 0..<64 {
                if index == -1 || characterCount[i].count >= countAtIndex {
                    index = i
                    countAtIndex = characterCount[i].count
                }
            }
            if index != -1 {
                positions.append(index)
                characterCount[index].removeAll()
                index = -1
                countAtIndex = 0
            } else {
                break
            }
        }
        return positions
    }
}
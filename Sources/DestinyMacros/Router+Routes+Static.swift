
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

                        routePaths.append("\(string)")
                        literalRouteResponders.append(responder)
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

        let namePrefix = "Case\(isCaseSensitive ? "S" : "Ins")ensitive"
        var enumDecl = StructDeclSyntax(
            leadingTrivia: "// MARK: \(namePrefix)StaticResponderStorage\(random)\n",
            name: "\(raw: namePrefix)StaticResponderStorage\(raw: random)",
            inheritanceClause: .init(
                inheritedTypes: .init(arrayLiteral:
                    .init(type: TypeSyntax.init(stringLiteral: "StaticResponderStorageProtocol"), trailingComma: ","),
                    .init(type: TypeSyntax.init(stringLiteral: "Copyable"))
                )
            ),
            memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax())
        )

        staticConstants(context: context, isCaseSensitive: isCaseSensitive, routePaths: routePaths, enumDecl: &enumDecl, literalRouteResponders: literalRouteResponders)

        generatedDecls.append(enumDecl)        
        return "\(enumDecl.name.text)()"

        var string = "\(typeAnnotation)(\n"
        if !mutable {
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
        }
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
        isCaseSensitive: Bool,
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
        enum StaticRoute: UInt16 {
        }
        """)
        for caseName in routePathCaseNames {
            routeConstantsDecl.memberBlock.members.append(.init(decl: try! EnumCaseDeclSyntax.init("case \(raw: caseName)")))
        }
        routeConstantsDecl.memberBlock.members.append(.init(decl: routeResponderDecl))
        routeConstantsDecl.memberBlock.members.append(contentsOf: staticResponders.map({ MemberBlockItemSyntax.init(decl: $0) }))
        enumDecl.memberBlock.members.append(.init(decl: routeConstantsDecl))

        if let perfectHashDecls = matchRoutePerfectHash(routePaths: routePaths, hashMaxBytes: 8) {
            enumDecl.memberBlock.members.append(contentsOf: perfectHashDecls.map({ .init(decl: $0) }))
        } else {
            enumDecl.memberBlock.members.append(contentsOf: staticSIMDs.map({ MemberBlockItemSyntax.init(decl: $0) }))
            enumDecl.memberBlock.members.append(.init(decl: matchRouteFallback(routePaths: routePaths)))
        }

        let responderDecl = try! FunctionDeclSyntax.init("""
        @inlinable
        func respond(
            router: some HTTPRouterProtocol,
            socket: Int32,
            request: inout some HTTPRequestProtocol & ~Copyable,
            completionHandler: @Sendable @escaping () -> Void
        ) throws(ResponderError) -> Bool {
            guard let route = matchRoute(request.startLine\(raw: isCaseSensitive ? "" : "Lowercased()")) else { return false }
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

// MARK: Match route
extension RouterStorage {
    private func matchRoutePerfectHash(
        routePaths: [String],
        hashMaxBytes: Int
    ) -> [any DeclSyntaxProtocol]? {
        let routePathSIMDs:[PerfectHashableItem<SIMD64<UInt8>>] = routePaths.compactMap({
            let utf8 = $0.utf8
            var simd = SIMD64<UInt8>.zero
            guard utf8.count > 0 else { return nil }
            for i in 0..<min(simd.scalarCount, utf8.count) {
                simd[i] = utf8[utf8.index(utf8.startIndex, offsetBy: i)]
            }
            return .init($0, simd)
        })

        let perfectHashGenerator = PerfectHashGenerator(routes: routePathSIMDs, maxBytes: hashMaxBytes)
        var candidate:HashCandidate? = nil
        var hashTable:[UInt8]? = nil
        var verificationKeys:[UInt64]? = nil
        if let result = perfectHashGenerator.findMinimalPerfectHash() {
            candidate = result.candidate
            hashTable = result.result.hashTable
            verificationKeys = result.result.verificationKeys
        } else if let result = perfectHashGenerator.generatePerfectHash() {
            candidate = result.candidate
            hashTable = result.hashTable
            verificationKeys = result.verificationKeys
        }
        guard let candidate, let hashTable, let verificationKeys else { return nil }
        let staticRoutesTableString = hashTable.map({
            guard $0 != 255 else { return "nil" }
            let key = verificationKeys[Int($0)]
            return ".init(.`\(routePaths[Int($0)])`, \(key))"
        }).joined(separator: ",\n")
        let hashTableDecl = VariableDeclSyntax.init(
            modifiers: .init(arrayLiteral: DeclModifierSyntax.init(name: "static")),
            .let,
            name: "hashTable",
            type: .init(type: TypeSyntax.init(stringLiteral: "InlineArray<\(hashTable.count), RouteEntry?>")),
            initializer: .init(leadingTrivia: " ", value: ExprSyntax.init(stringLiteral: "[\n\(staticRoutesTableString)\n]"))
        )

        let positions = perfectHashGenerator.positions

        var extractKeyLiteral = ""
        for offset in 0..<hashMaxBytes {
            var s = "UInt64(simd[\(positions[offset])])"
            if offset != 0 {
                s = "\n    | (\(s) << \(offset * hashMaxBytes))"
            }
            extractKeyLiteral += s
        }

        let extractKeyDecl = try! FunctionDeclSyntax.init("""
        @inlinable @inline(__always)
        func extractKey(_ simd: SIMD64<UInt8>) -> UInt64 {
            return \(raw: extractKeyLiteral)
        }
        """)

        let perfectHashDecl = try! FunctionDeclSyntax.init("""
        @inlinable @inline(__always)
        func perfectHash(
            _ simd: SIMD64<UInt8>
        ) -> (key: UInt64, hash: Int) {
            let key = extractKey(simd)
            return (key, Int(((key &* \(raw: candidate.multiplier)) >> \(raw: candidate.shift)) & \(raw: candidate.mask)))
        }
        """)

        let routeEntryDecl = try! StructDeclSyntax.init("""
        struct RouteEntry: Sendable {
            let key:UInt64
            let route:StaticRoute
            init(_ route: StaticRoute, _ key: UInt64) {
                self.route = route
                self.key = key
            }
        }
        """)

        let additionalCheck = hashTable.count != 1 ? "" : """
        guard hashIndex < \(hashTable.count) else { return nil }
        """

        let matchRouteDecl = try! FunctionDeclSyntax.init("""
        @inlinable @inline(__always)
        func matchRoute(_ simd: SIMD64<UInt8>) -> StaticRoute? {
            let (key, hashIndex) = perfectHash(simd)
            \(raw: additionalCheck)guard let entry = Self.hashTable[hashIndex] else { return nil }
            if entry.key != key { // hash collision
                return nil
            }
            return entry.route
        }
        """)
        return [
            routeEntryDecl,
            hashTableDecl,
            extractKeyDecl,
            perfectHashDecl,
            matchRouteDecl
        ]
    }

    private func matchRouteFallback(
        routePaths: [String]
    ) -> FunctionDeclSyntax {
        return try! FunctionDeclSyntax.init("""
        @inlinable
        func matchRoute(_ simd: SIMD64<UInt8>) -> StaticRoute? {
            switch simd {
            \(raw: (0..<routePaths.count).map({ "case Self.simd\($0): .`\(routePaths[$0])`" }).joined(separator: "\n"))
            default: nil
            }
        }
        """)
    }
}

import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: ExpressionMacro
enum Router: ExpressionMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let args = node.as(ExprSyntax.self)!.macroExpansion!.arguments
        let router = declaredRouter(context: context, arguments: args)
        return "\(raw: router)"
    }
}

// MARK: DeclarationMacro
extension Router: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        let arguments:LabeledExprListSyntax
        if let args = node.as(MacroExpansionExprSyntax.self)?.arguments {
            arguments = args
        } else if let args = node.as(MacroExpansionDeclSyntax.self)?.arguments {
            arguments = args
        } else {
            fatalError("node=\(node.debugDescription)")
        }
        let router = declaredRouter(context: context, arguments: arguments)
        return [.init(router)]
    }
}

// MARK: DeclaredRouter
extension Router {
    static func declaredRouter(
        context: some MacroExpansionContext,
        arguments: LabeledExprListSyntax
    ) -> StructDeclSyntax {
        let (storage, structs) = build(context: context, arguments: arguments)
        var declaredRouter = StructDeclSyntax(
            modifiers: [storage.visibilityModifier],
            name: "DeclaredRouter",
            memberBlock: .init(members: structs)
        )

        let routerDecl = VariableDeclSyntax(
            leadingTrivia: .init(stringLiteral: "\(inlinableAnnotation)\n"),
            modifiers: [storage.visibilityModifier, .init(name: .keyword(.static))],
            .var,
            name: "router",
            type: .init(type: TypeSyntax(stringLiteral: "\(storage.name)")),
            accessorBlock: .init(stringLiteral: "{ \(storage.name)() }")
        )
        declaredRouter.memberBlock.members.append(routerDecl)
        declaredRouter.memberBlock.members.append(storage.build(context: context))
        return declaredRouter
    }
}

// MARK: Build
extension Router {
    static func build(
        context: some MacroExpansionContext,
        arguments: LabeledExprListSyntax
    ) -> (storage: CompiledRouterStorage, structs: MemberBlockItemListSyntax) {
        let routerSettingsSyntax = arguments.first!.expression
        #if RouterSettings
        var routerSettings = RouterSettings()
        #endif
        var perfectHashSettings = PerfectHashSettings()
        for arg in arguments {
            switch arg.label?.text {
            #if RouterSettings
            case "routerSettings":
                routerSettings = .parse(context: context, expr: arg.expression)
            #endif
            case "perfectHashSettings":
                perfectHashSettings = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        #if RouterSettings
        return compute(
            routerSettings: routerSettings,
            routerSettingsSyntax: routerSettingsSyntax,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        #else
        return compute(
            routerSettingsSyntax: routerSettingsSyntax,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        #endif
    }
}

// MARK: Diagnostics
extension Router {
    static func routePathAlreadyRegistered(
        context: some MacroExpansionContext,
        node: some SyntaxProtocol,
        _ string: String
    ) {
        context.diagnose(.init(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Redirects
extension Router {
    #if StaticRedirectionRoute
    static func parseRedirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        array: ArrayElementListSyntax,
        staticRedirects: inout [(StaticRedirectionRoute, FunctionCallExprSyntax)]
    ) {
        for methodElement in array {
            if let function = methodElement.expression.functionCall {
                switch methodElement.expression.functionCall?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                case "StaticRedirectionRoute":
                    let route = StaticRedirectionRoute.parse(context: context, version: version, function)
                    staticRedirects.append((route, function))
                default:
                    context.diagnose(DiagnosticMsg.unhandled(node: function))
                }
            } else {
                context.diagnose(DiagnosticMsg.unhandled(node: methodElement))
            }
        }
    }
    #endif
}

// MARK: RoutePath
struct RoutePath: Hashable {
    let comment:String
    let path:SIMD64<UInt8>
}

import DestinyDefaults
import DestinyBlueprint
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
        let computed:(router: CompiledRouterStorage, structs: MemberBlockItemListSyntax)

        #if RouterSettings
        computed = compute(
            routerSettings: .init(),
            routerSettingsSyntax: args.first!.expression,
            perfectHashSettings: .init(),
            arguments: args,
            context: context
        )
        #else
        computed = compute(
            routerSettingsSyntax: args.first!.expression,
            perfectHashSettings: .init(),
            arguments: args,
            context: context
        )
        #endif
        return "\(raw: computed.router)"
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

        let routerSettingsSyntax = arguments.first!.expression
        #if RouterSettings
        var settings = RouterSettings()
        #endif
        var perfectHashSettings = PerfectHashSettings()
        for arg in arguments {
            switch arg.label?.text {
            #if RouterSettings
            case "routerSettings":
                settings = .parse(context: context, expr: arg.expression)
            #endif
            case "perfectHashSettings":
                perfectHashSettings = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        let (router, structs):(router: CompiledRouterStorage, structs: MemberBlockItemListSyntax)

        #if RouterSettings
        (router, structs) = compute(
            routerSettings: settings,
            routerSettingsSyntax: routerSettingsSyntax,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        #else
        (router, structs) = compute(
            routerSettingsSyntax: routerSettingsSyntax,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        #endif
        var declaredRouter = StructDeclSyntax(
            modifiers: [router.visibilityModifier],
            name: "DeclaredRouter",
            memberBlock: .init(members: .init())
        )
        declaredRouter.memberBlock.members.append(contentsOf: structs)

        let routerDecl = VariableDeclSyntax(
            leadingTrivia: .init(stringLiteral: "\(inlinableAnnotation)\n"),
            modifiers: [router.visibilityModifier, .init(name: .keyword(.static))],
            .var,
            name: "router",
            type: .init(type: TypeSyntax(stringLiteral: "\(router.name)")),
            accessorBlock: .init(stringLiteral: "{ \(router.name)() }")
        )
        declaredRouter.memberBlock.members.append(routerDecl)
        declaredRouter.memberBlock.members.append(router.build(context: context))
        return [.init(declaredRouter)]
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
        staticRedirects: inout [(StaticRedirectionRoute, FunctionCallExprSyntax)],
        dynamicRedirects: inout [(any RedirectionRouteProtocol, FunctionCallExprSyntax)]
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

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
        let computed = compute(
            routerSettings: .init(),
            perfectHashSettings: .init(),
            arguments: node.as(ExprSyntax.self)!.macroExpansion!.arguments,
            context: context
        )
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

        var settings = RouterSettings()
        var perfectHashSettings = PerfectHashSettings()
        for arg in arguments {
            switch arg.label?.text {
            case "routerSettings":
                settings = .parse(context: context, expr: arg.expression)
            case "perfectHashSettings":
                perfectHashSettings = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        let (router, structs) = compute(
            routerSettings: settings,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        var declaredRouter = StructDeclSyntax(
            modifiers: [router.visibilityModifier],
            name: "DeclaredRouter",
            memberBlock: .init(members: .init())
        )
        declaredRouter.memberBlock.members.append(contentsOf: structs)
        
        let routerDecl:VariableDeclSyntax
        if settings.isCopyable {
            routerDecl = VariableDeclSyntax(
                modifiers: [router.visibilityModifier, .init(name: .keyword(.static))],
                .let,
                name: "router",
                initializer: .init(value: ExprSyntax("\(raw: settings.name)()"))
            )
        } else {
            routerDecl = VariableDeclSyntax(
                leadingTrivia: .init(stringLiteral: "\(inlinableAnnotation)\n"),
                modifiers: [router.visibilityModifier, .init(name: .keyword(.static))],
                .var,
                name: "router",
                type: .init(type: TypeSyntax(stringLiteral: "\(settings.name)")),
                accessorBlock: .init(stringLiteral: "{ \(settings.name)() }")
            )
        }
        declaredRouter.memberBlock.members.append(routerDecl)
        declaredRouter.memberBlock.members.append(router.build())
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
}

// MARK: RoutePath
struct RoutePath: Hashable {
    let comment:String
    let path:SIMD64<UInt8>
}
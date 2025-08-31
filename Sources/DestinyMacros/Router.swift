
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
    ) throws -> ExprSyntax {
        let computed = compute(
            visibility: .internal,
            mutable: true,
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
    ) throws -> [DeclSyntax] {
        let arguments:LabeledExprListSyntax
        if let args = node.as(MacroExpansionExprSyntax.self)?.arguments {
            arguments = args
        } else if let args = node.as(MacroExpansionDeclSyntax.self)?.arguments {
            arguments = args
        } else {
            fatalError("node=\(node.debugDescription)")
        }

        var visibility = RouterVisibility.internal
        var mutable = true
        var typeAnnotation:String? = nil
        var perfectHashSettings = PerfectHashSettings()
        for arg in arguments {
            switch arg.label?.text {
            case "visibility":
                visibility = .init(rawValue: arg.expression.memberAccess?.declName.baseName.text ?? "internal") ?? .internal
            case "mutable":
                mutable = arg.expression.booleanIsTrue
            case "typeAnnotation":
                typeAnnotation = arg.expression.stringLiteralString(context: context)
            case "perfectHashSettings":
                perfectHashSettings = .parse(context: context, expr: arg.expression)
            default:
                break
            }
        }
        let (router, structs) = compute(
            visibility: visibility,
            mutable: mutable,
            perfectHashSettings: perfectHashSettings,
            arguments: arguments,
            context: context
        )
        var declaredRouter = StructDeclSyntax(
            leadingTrivia: "\(visibility)",
            name: "DeclaredRouter",
            memberBlock: .init(members: .init())
        )
        for s in structs {
            declaredRouter.memberBlock.members.append(.init(decl: s))
        }
        
        let routerDecl = VariableDeclSyntax(
            leadingTrivia: .init(stringLiteral: "\(visibility)"),
            modifiers: [DeclModifierSyntax(name: "static")],
            .let,
            name: "router",
            type: typeAnnotation == nil ? nil : .init(type: TypeSyntax.init(stringLiteral: typeAnnotation!)),
            initializer: .init(value: ExprSyntax(stringLiteral: "CompiledHTTPRouter()"))
        )
        declaredRouter.memberBlock.members.append(.init(decl: routerDecl))
        declaredRouter.memberBlock.members.append(.init(decl: router.build()))
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
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Redirects
extension Router {
    static func parseRedirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        array: ArrayElementListSyntax,
        staticRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)],
        dynamicRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)]
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
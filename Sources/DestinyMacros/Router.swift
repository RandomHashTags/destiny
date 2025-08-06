
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
        return "\(raw: compute(mutable: true, arguments: node.as(ExprSyntax.self)!.macroExpansion!.arguments, context: context).router)"
    }
}

// MARK: DeclarationMacro
extension Router: DeclarationMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var mutable = true
        var typeAnnotation:String? = nil
        let arguments = node.as(ExprSyntax.self)!.macroExpansion!.arguments
        for arg in arguments.prefix(2) {
            switch arg.label?.text {
            case "mutable":
                mutable = arg.expression.booleanIsTrue
            case "typeAnnotation":
                typeAnnotation = arg.expression.stringLiteralString(context: context)
            default:
                break
            }
        }
        let (router, structs) = compute(mutable: mutable, arguments: arguments, context: context)
        var declaredRouter = try! StructDeclSyntax("struct DeclaredRouter {}")
        for s in structs {
            declaredRouter.memberBlock.members.append(MemberBlockItemSyntax(decl: s))
        }
        let routerDecl = VariableDeclSyntax(
            leadingTrivia: .init(stringLiteral: "// MARK: compiled router\n"),
            modifiers: [DeclModifierSyntax(name: "static")],
            .let,
            name: "router",
            type: typeAnnotation == nil ? nil : .init(type: TypeSyntax.init(stringLiteral: typeAnnotation!)),
            initializer: .init(value: ExprSyntax(stringLiteral: router))
        )
        declaredRouter.memberBlock.members.append(MemberBlockItemSyntax(decl: routerDecl))
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
    let path:DestinyRoutePathType
}
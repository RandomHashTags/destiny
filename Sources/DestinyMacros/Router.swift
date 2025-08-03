
import DestinyDefaults
import DestinyBlueprint
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: ExpressionMacro
enum Router: ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        return "\(raw: compute(arguments: node.as(ExprSyntax.self)!.macroExpansion!.arguments, context: context).router)"
    }
}

// MARK: DeclarationMacro
extension Router: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var mutable = false
        var typeAnnotation:String? = nil
        let arguments = node.as(ExprSyntax.self)!.macroExpansion!.arguments
        for arg in arguments.prefix(2) {
            switch arg.label?.text {
            case "mutable":
                mutable = arg.expression.booleanIsTrue
            case "typeAnnotation":
                guard let string = arg.expression.stringLiteral?.string else {
                    context.diagnose(DiagnosticMsg.expectedStringLiteral(expr: arg.expression))
                    break
                }
                typeAnnotation = string
            default:
                break
            }
        }
        var decls = [DeclSyntax]()
        let (router, structs) = compute(arguments: arguments, context: context)
        decls.append(contentsOf: structs.map({ .init($0) }))
        var string = "// MARK: Router\nstruct DeclaredRouter {\n"
        string += "static \(mutable ? "var" : "let") router"
        if let typeAnnotation {
            string += ":" + typeAnnotation
        }
        string += " = " + router
        string += "\n}"
        decls.append("\(raw: string)")
        return decls
    }
}

// MARK: Diagnostics
extension Router {
    static func routePathAlreadyRegistered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Redirects
extension Router {
    static func parseRedirects(
        context: some MacroExpansionContext,
        version: HTTPVersion,
        array: ArrayExprSyntax,
        staticRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)],
        dynamicRedirects: inout [(any RedirectionRouteProtocol, SyntaxProtocol)]
    ) {
        for methodElement in array.elements {
            if let function = methodElement.expression.functionCall {
                switch methodElement.expression.functionCall?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text {
                case "StaticRedirectionRoute":
                    if let route = StaticRedirectionRoute.parse(context: context, version: version, function) {
                        staticRedirects.append((route, function))
                    }
                default:
                    context.diagnose(DiagnosticMsg.unhandled(node: methodElement))
                }
            }
        }
    }
}

extension Router.Storage {
    struct Route {
        let startLine:String
        let buffer:DestinyRoutePathType
        let responder:String

        var path: Substring {
            startLine.split(separator: " ")[1]
        }
        var paths: [Substring] {
            path.split(separator: "/")
        }
    }
}

// MARK: RoutePath
struct RoutePath: Hashable {
    let comment:String
    let path:DestinyRoutePathType
}
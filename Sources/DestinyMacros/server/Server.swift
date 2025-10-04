
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: ExpressionMacro
enum Server: ExpressionMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let args = node.as(ExprSyntax.self)!.macroExpansion!.arguments
        let decl = build(context: context, arguments: args)
        return "\(raw: decl)"
    }
}

// MARK: DeclarationMacro
extension Server: DeclarationMacro {
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
        let router = build(context: context, arguments: arguments)
        return [.init(router)]
    }
}

// MARK: Build
extension Server {
    static func build(
        context: some MacroExpansionContext,
        arguments: LabeledExprListSyntax
    ) -> StructDeclSyntax {
        var server = CompiledHTTPServer()
        for arg in arguments {
            switch arg.label?.text {
            case "noncopyable":
                server.noncopyable = arg.expression.booleanIsTrue
            case "logging":
                server.logging = arg.expression.booleanIsTrue

            case "address":
                server.address = arg.expression.description
            case "port":
                server.port = arg.expression.description
            case "backlog":
                server.backlog = arg.expression.description
            case "routerType":
                server.routerType = arg.expression.stringLiteralString(context: context) ?? server.routerType
            case "reuseAddress":
                server.reuseAddress = arg.expression.booleanIsTrue
            case "reusePort":
                server.reusePort = arg.expression.booleanIsTrue
            case "noTCPDelay":
                server.noTCPDelay = arg.expression.booleanIsTrue
            case "maxEpollEvents":
                server.maxEpollEvents = arg.expression.description
            case "socket":
                server.socketType = arg.expression.stringLiteralString(context: context) ?? server.socketType
            case "onLoad":
                server.onLoad = arg.expression.description
            case "onShutdown":
                server.onShutdown = arg.expression.description
            default:
                break
            }
        }
        return server.build(name: "Server")
    }
}
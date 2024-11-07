//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftDiagnostics
//import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacros

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        /*let arguments = node.macroExpansion!.arguments
        let test:Test = Router.restructure(arguments: arguments)
        print("Router;expansion;test;restructure;test=\(test)")*/
        var version:String = "HTTP/1.1"
        var static_middleware:[StaticMiddlewareProtocol] = []
        var dynamic_middleware:[DynamicMiddlewareProtocol] = []
        var static_routes:[(StaticRouteProtocol, FunctionCallExprSyntax)] = []
        var dynamic_routes:[DynamicRouteProtocol] = []
        for argument in node.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "version":
                            version = child.expression.stringLiteral!.string
                            break
                        case "middleware":
                            for element in child.expression.array!.elements {
                                //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                                if let function:FunctionCallExprSyntax = element.expression.functionCall {
                                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                                        dynamic_middleware.append(DynamicMiddleware.parse(function))
                                    } else {
                                        static_middleware.append(StaticMiddleware.parse(function))
                                    }
                                } else if let macro_expansion:MacroExpansionExprSyntax = element.expression.macroExpansion {
                                    // TODO: support custom middleware
                                } else {
                                }
                            }
                            break
                        default:
                            break
                    }
                } else if let function:FunctionCallExprSyntax = child.expression.functionCall { // route
                    //print("Router;expansion;route;function=\(function)")
                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                        if let route:DynamicRouteProtocol = DynamicRoute.parse(context: context, version: version, middleware: static_middleware, function) {
                            dynamic_routes.append(route)
                        }
                    } else if let route:StaticRouteProtocol = StaticRoute.parse(context: context, function) {
                        static_routes.append((route, function))
                    }
                } else {
                    // TODO: support custom routes
                }
            }
        }
        let static_responses:String = parse_static_routes_string(context: context, version: version, middleware: static_middleware, static_routes)
        let dynamic_routes_string:String = parse_dynamic_routes_string(version: version, dynamic_routes)
        let static_middleware_string:String = static_middleware.isEmpty ? "" : "\n" + static_middleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n"
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({ $0.debugDescription }).joined(separator: ",\n") + "\n"
        return "\(raw: "Router(\nversion: \"\(version)\",\nstaticResponses: [\(static_responses)],\ndynamicResponses: \(dynamic_routes_string),\nstaticMiddleware: [\(static_middleware_string)],\ndynamicMiddleware: [\(dynamic_middleware_string)]\n)")"
    }
}
// MARK: Parse static routes string
private extension Router {
    static func parse_static_routes_string(context: some MacroExpansionContext, version: String, middleware: [StaticMiddlewareProtocol], _ routes: [(StaticRouteProtocol, FunctionCallExprSyntax)]) -> String {
        return routes.isEmpty ? ":" : "\n" + routes.compactMap({ (route, function) in
            do {
                let response:String = try route.response(version: version, middleware: middleware)
                let value:String = route.returnType.encode(response)
                var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
                let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                return "// \(string)\n\(buffer) : " + value
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n") + "\n"
    }
}
// MARK: Parse dynamic routes string
private extension Router {
    static func parse_dynamic_routes_string(version: String, _ routes: [DynamicRouteProtocol]) -> String {
        var parameterized:[DynamicRouteProtocol] = []
        var parameterless:[DynamicRouteProtocol] = []
        for route in routes {
            if route.path.first(where: { $0.isParameter }) != nil {
                parameterized.append(route)
            } else {
                parameterless.append(route)
            }
        }
        let parameterless_string:String = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route in
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + version
            let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
            let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
            let responder:String = route.responder(logic: logic)
            return "// \(string)\n\(buffer) : \(responder)"
        }).joined(separator: ",\n") + "\n"
        var parameterized_by_path_count:[String] = []
        var parameterized_string:String = ""
        if !parameterized.isEmpty {
            for route in parameterized {
                if parameterized_by_path_count.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized_by_path_count.count) {
                        parameterized_by_path_count.append("")
                    }
                }
                let string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + version
                let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
                let responder:String = route.responder(logic: logic)
                parameterized_by_path_count[route.path.count].append("\n// \(string)\n" + responder)
            }
            parameterized_string = "\n" + parameterized_by_path_count.map({ "[\($0.isEmpty ? "" : $0 + "\n")]" }).joined(separator: ",\n") + "\n"
        }
        return "DynamicResponses(\nparameterless: [\(parameterless_string)],\nparameterized: [\(parameterized_string)])"
    }
}

protocol Restructurable {
    /// The macro arguments to decode at compile time.
    static var variables : Set<String> { get }

    init()

    /// Assigned at compile time.
    mutating func assign(variable: String, value: Any?)

    /// Computed at compile time.
    static func handleFunction(variable: String, function: FunctionCallExprSyntax) -> Any?

    static func handleMacroExpansion(variable: String, expansion: MacroExpansionExprSyntax) -> Any?
}

struct Test : Restructurable {
    static let variables:Set<String> = ["version", "middleware"]

    var version:String
    var static_middleware:[StaticMiddlewareProtocol]
    var dynamic_middleware:[DynamicMiddlewareProtocol]

    init() {
        version = ""
        static_middleware = []
        dynamic_middleware = []
    }

    mutating func assign(variable: String, value: Any?) {
        switch variable {
            case "version": version = value as! String
            case "middleware":
                let middleware:[MiddlewareProtocol] = value as! [MiddlewareProtocol]
                static_middleware = middleware.compactMap({ $0 as? StaticMiddlewareProtocol })
                dynamic_middleware = middleware.compactMap({ $0 as? DynamicMiddlewareProtocol })
                break
            default: break
        }
    }

    static func handleFunction(variable: String, function: FunctionCallExprSyntax) -> Any? {
        switch variable {
            case "middleware":
                if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                    return DynamicMiddleware.parse(function)
                } else {
                    return StaticMiddleware.parse(function)
                }
            default:
                return nil
        }
    }

    static func handleMacroExpansion(variable: String, expansion: MacroExpansionExprSyntax) -> Any? {
        return nil
    }
}

extension Router {
    static func restructure<T: Restructurable>(arguments: LabeledExprListSyntax) -> T {
        var value:T = T()
        for argument in arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    if T.variables.contains(key) {
                        value.assign(variable: key, value: restructure_expression(value, key: key, child.expression))
                    }
                }
            }
        }
        return value
    }
    static func restructure_expression<T : Restructurable>(_ structure: T, key: String, _ expr: ExprSyntax) -> Any? {
        if let string:String = expr.stringLiteral?.string
            ?? expr.as(IntegerLiteralExprSyntax.self)?.literal.text
            ?? expr.as(FloatLiteralExprSyntax.self)?.literal.text {
            return string
        }
        if let decl = expr.memberAccess?.declName.baseName.text {
            return decl
        }
        if let function:FunctionCallExprSyntax = expr.functionCall {
            return T.handleFunction(variable: key, function: function)
        }
        if let expansion:MacroExpansionExprSyntax = expr.macroExpansion {
            return T.handleMacroExpansion(variable: key, expansion: expansion)
        }
        if let array:ArrayElementListSyntax = expr.array?.elements {
            return array.map({ restructure_expression(structure, key: key, $0.expression) })
        }
        if let closure:ClosureExprSyntax = expr.as(ClosureExprSyntax.self) {
        }
        return nil
    }
}
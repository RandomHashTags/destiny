//
//  Router.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyDefaults
import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum Router : ExpressionMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        /*let arguments = node.macroExpansion!.arguments
        let test:Test = Router.restructure(arguments: arguments)
        print("Router;expansion;test;restructure;test=\(test)")*/
        var version:HTTPVersion = .v1_1
        var static_middleware:[StaticMiddleware] = []
        var dynamic_middleware:[DynamicMiddlewareProtocol] = []
        var static_routes:[(StaticRoute, FunctionCallExprSyntax)] = []
        var dynamic_routes:[(DynamicRoute, FunctionCallExprSyntax)] = []
        for argument in node.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "version":
                            if let parsed:HTTPVersion = HTTPVersion.parse(child.expression) {
                                version = parsed
                            }
                            break
                        case "middleware":
                            for element in child.expression.array!.elements {
                                //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                                if let function:FunctionCallExprSyntax = element.expression.functionCall {
                                    let decl:String = function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text
                                    switch decl {
                                        case "DynamicMiddleware":     dynamic_middleware.append(DynamicMiddleware.parse(function))
                                        case "DynamicCORSMiddleware": dynamic_middleware.append(DynamicCORSMiddleware.parse(function))
                                        case "StaticMiddleware":      static_middleware.append(StaticMiddleware.parse(function))
                                        default: break
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
                        if let route:DynamicRoute = DynamicRoute.parse(context: context, version: version, middleware: static_middleware, function) {
                            dynamic_routes.append((route, function))
                        }
                    } else if let route:StaticRoute = StaticRoute.parse(context: context, version: version, function) {
                        static_routes.append((route, function))
                    }
                } else {
                    // TODO: support custom routes
                }
            }
        }
        let static_responses:String = parse_static_routes_string(context: context, middleware: static_middleware, static_routes)
        let dynamic_routes_string:String = parse_dynamic_routes_string(context: context, dynamic_routes)
        let static_middleware_string:String = static_middleware.isEmpty ? "" : "\n" + static_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({ "\($0)" }).joined(separator: ",\n") + "\n"
        return "\(raw: "Router(\nstaticResponses: [\(static_responses)],\ndynamicResponses: \(dynamic_routes_string),\nstaticMiddleware: [\(static_middleware_string)],\ndynamicMiddleware: [\(dynamic_middleware_string)]\n)")"
    }
}

private extension Router {
    static func route_path_already_registered(context: some MacroExpansionContext, node: some SyntaxProtocol, _ string: String) {
        context.diagnose(Diagnostic(node: node, message: DiagnosticMsg(id: "routePathAlreadyRegistered", message: "Route path (\(string)) already registered.")))
    }
}

// MARK: Parse static routes string
private extension Router {
    static func parse_static_routes_string(context: some MacroExpansionContext, middleware: [StaticMiddleware], _ routes: [(StaticRoute, FunctionCallExprSyntax)]) -> String {
        var registered_paths:Set<String> = []
        registered_paths.reserveCapacity(routes.count)
        return routes.isEmpty ? ":" : "\n" + routes.compactMap({ (route, function) in
            do {
                var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + route.version.string
                if registered_paths.contains(string) {
                    route_path_already_registered(context: context, node: function, string)
                    return nil
                } else {
                    registered_paths.insert(string)
                    let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                    let response:String = try route.response(middleware: middleware)
                    let value:String = route.returnType.encode(response)
                    return "// \(string)\n\(buffer) : " + value
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n") + "\n"
    }
}
// MARK: Parse dynamic routes string
private extension Router {
    static func parse_dynamic_routes_string(context: some MacroExpansionContext, _ routes: [(DynamicRoute, FunctionCallExprSyntax)]) -> String {
        var parameterized:[(DynamicRoute, FunctionCallExprSyntax)] = []
        var parameterless:[(DynamicRoute, FunctionCallExprSyntax)] = []
        for route in routes {
            if route.0.path.first(where: { $0.isParameter }) != nil {
                parameterized.append(route)
            } else {
                parameterless.append(route)
            }
        }
        var registered_paths:Set<String> = []
        registered_paths.reserveCapacity(routes.count)
        let parameterless_string:String = parameterless.isEmpty ? ":" : "\n" + parameterless.compactMap({ route, function in
            var string:String = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + route.version.string
            if registered_paths.contains(string) {
                route_path_already_registered(context: context, node: function, string)
                return nil
            } else {
                registered_paths.insert(string)
                let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
                let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
                let responder:String = route.responder(logic: logic)
                return "// \(string)\n\(buffer) : \(responder)"
            }
        }).joined(separator: ",\n") + "\n"
        var parameterized_by_path_count:[String] = []
        var parameterized_string:String = ""
        if !parameterized.isEmpty {
            for (route, function) in parameterized {
                if parameterized_by_path_count.count <= route.path.count {
                    for _ in 0...(route.path.count - parameterized_by_path_count.count) {
                        parameterized_by_path_count.append("")
                    }
                }
                var string:String = route.method.rawValue + " /" + route.path.map({ $0.isParameter ? ":any_parameter" : $0.slug }).joined(separator: "/") + " " + route.version.string
                if !registered_paths.contains(string) {
                    registered_paths.insert(string)
                    string = route.method.rawValue + " /" + route.path.map({ $0.slug }).joined(separator: "/") + " " + route.version.string
                    let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
                    let responder:String = route.responder(logic: logic)
                    parameterized_by_path_count[route.path.count].append("\n// \(string)\n" + responder)
                } else {
                    route_path_already_registered(context: context, node: function, string)
                }
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
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
        var returnType:RouterReturnType = .staticString
        var version:String = "HTTP/1.1"
        var middleware:[any MiddlewareProtocol] = []
        var routes:[(RouteProtocol, FunctionCallExprSyntax)] = []
        for argument in node.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "returnType":
                            returnType = RouterReturnType(rawValue: child.expression.memberAccess!.declName.baseName.text)!
                            break
                        case "version":
                            version = child.expression.stringLiteral!.string
                            break
                        case "middleware":
                            for element in child.expression.array!.elements {
                                //print("Router;expansion;key==middleware;element.expression=\(element.expression.debugDescription)")
                                if let function:FunctionCallExprSyntax = element.expression.functionCall {
                                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                                        middleware.append(DynamicMiddleware.parse(function))
                                    } else {
                                        middleware.append(StaticMiddleware.parse(function))
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
                    // TODO: check whether it is static or dynamic
                    //print("Router;expansion;route;function=\(function)")
                    if function.calledExpression.as(DeclReferenceExprSyntax.self)!.baseName.text.starts(with: "Dynamic") {
                        routes.append((DynamicRoute.parse(version: version, middleware: middleware.compactMap({ $0 as? StaticMiddlewareProtocol }), function), function))
                    } else {
                        routes.append((StaticRoute.parse(function), function))
                    }
                } else {
                    // TODO: support custom routes
                }
            }
        }
        let get_returned_type:(String) -> String
        func bytes<T: FixedWidthInteger>(_ bytes: [T]) -> String {
            return "[" + bytes.map({ "\($0)" }).joined(separator: ",") + "]"
        }
        func response(valueType: String, _ string: String) -> String {
            return "RouteResponses." + valueType + "(" + string + ")"
        }
        switch returnType {
            case .uint8Array:
                get_returned_type = { response(valueType: "UInt8Array", bytes([UInt8]($0.utf8))) }
                break
            case .uint16Array:
                get_returned_type = { response(valueType: "UInt16Array", bytes([UInt16]($0.utf16))) }
                break
            case .data:
                get_returned_type = { response(valueType: "Data", bytes([UInt8]($0.utf8))) }
                break
            case .unsafeBufferPointer:
                get_returned_type = { response(valueType: "UnsafeBufferPointer", "StaticString(\"" + $0 + "\").withUTF8Buffer { $0 }") }
                break
            default:
                get_returned_type = { response(valueType: "StaticString", "\"" + $0 + "\"") }
                break
        }
        let static_routes:[(StaticRouteProtocol, FunctionCallExprSyntax)] = routes.compactMap({ $0.0 is StaticRouteProtocol ? ($0.0 as! StaticRouteProtocol, $0.1) : nil })
        let dynamic_routes:[DynamicRouteProtocol] = routes.compactMap({ $0.0 as? DynamicRouteProtocol })
        let static_middleware:[StaticMiddlewareProtocol] = middleware.compactMap({ $0 as? StaticMiddlewareProtocol })
        let dynamic_middleware:[DynamicMiddlewareProtocol] = middleware.compactMap({ $0 as? DynamicMiddlewareProtocol })
        let static_responses:String = static_routes.isEmpty ? ":" : "\n" + static_routes.compactMap({ (route, function) in
            do {
                let response:String = try route.response(version: version, middleware: static_middleware)
                let value:String = get_returned_type(response)
                var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
                let buffer:StackString32 = StackString32(&string)
                return "// \(string)\n\(buffer) : " + value
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
                return nil
            }
        }).joined(separator: ",\n") + "\n"
        let dynamic_routes_string:String = dynamic_routes.isEmpty ? ":" : "\n" + dynamic_routes.compactMap({ route in
            var string:String = route.method.rawValue + " /" + route.path.joined(separator: "/") + " " + version
            let buffer:StackString32 = StackString32(&string)
            let logic:String = route.isAsync ? route.handlerLogicAsync : route.handlerLogic
            let responder:String = route.responder(version: version, logic: logic)
            return "// \(string)\n\(buffer) : \(responder)"
        }).joined(separator: ",\n") + "\n"
        let dynamic_middleware_string:String = dynamic_middleware.isEmpty ? "" : "\n" + dynamic_middleware.map({
            return $0.description
        }).joined(separator: ",\n") + "\n"
        return "\(raw: "Router(\nstaticResponses: [\(static_responses)],\ndynamicResponses: [\(dynamic_routes_string)],\ndynamicMiddleware: [\(dynamic_middleware_string)]\n)")"
    }
}

// MARK: Misc
extension SyntaxProtocol {
    var macroExpansion : MacroExpansionExprSyntax? { self.as(MacroExpansionExprSyntax.self) }
    var functionCall : FunctionCallExprSyntax? { self.as(FunctionCallExprSyntax.self) }
    var stringLiteral : StringLiteralExprSyntax? { self.as(StringLiteralExprSyntax.self) }
    var memberAccess : MemberAccessExprSyntax? { self.as(MemberAccessExprSyntax.self) }
    var array : ArrayExprSyntax? { self.as(ArrayExprSyntax.self) }
    var dictionary : DictionaryExprSyntax? { self.as(DictionaryExprSyntax.self) }
}

extension StringLiteralExprSyntax {
    var string : String { "\(segments)" }
}
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
        var middleware:[any MiddlewareProtocol] = [], routes:[RouteProtocol] = []
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
                                    // TODO: check whether it is static or dynamic
                                    middleware.append(StaticMiddleware.parse(function))
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
                    routes.append(StaticRoute.parse(function))
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
        let static_routes:[StaticRouteProtocol] = routes.compactMap({ $0.routeType == .static ? ($0 as! StaticRouteProtocol) : nil })
        let static_middleware:[StaticMiddlewareProtocol] = middleware.compactMap({ $0.middlewareType == .static ? ($0 as! StaticMiddlewareProtocol) : nil })
        let static_responses:String = static_routes.map({
            let value:String = get_returned_type($0.response(version: version, middleware: static_middleware))
            var string:String = $0.method.rawValue + " /" + $0.path + " " + version
            var length:Int = 32
            var buffer:String = ""
            string.withUTF8 { p in
                let amount:Int = min(p.count, length)
                for i in 0..<amount {
                    buffer += (i == 0 ? "" : ", ") + "\(p[i])"
                }
                length -= amount
            }
            for _ in 0..<length {
                buffer += ", 0"
            }
            return "// \(string)\nStackString32(\(buffer)):" + value
        }).joined(separator: ",\n")
        return "\(raw: "Router(staticResponses: [\n" + (static_responses.isEmpty ? ":" : static_responses) + "\n])")"
    }
}

// MARK: Parse Middleware
extension Router {
    static func parse_middleware(_ array: ArrayElementListSyntax) {
        //let test = Parser.parse(source: "public struct StaticMiddleware : StaticMiddlewareProtocol { public static func parse(_ function: FunctionCallExprSyntax) -> Self { return Self() } public init() {} }")
        //test.statements.first!.item.as(StructDeclSyntax.self)!.memberBlock.members.first!.decl.as(FunctionDeclSyntax.self)!
        //print("Router;parse_middlewarae;test=" + test.debugDescription)
        /*
        Router;parse_middleware;test=SourceFileSyntax
        ├─statements: CodeBlockItemListSyntax
        │ ╰─[0]: CodeBlockItemSyntax
        │   ╰─item: StructDeclSyntax
        │     ├─attributes: AttributeListSyntax
        │     ├─modifiers: DeclModifierListSyntax
        │     │ ╰─[0]: DeclModifierSyntax
        │     │   ╰─name: keyword(SwiftSyntax.Keyword.public)
        │     ├─structKeyword: keyword(SwiftSyntax.Keyword.struct)
        │     ├─name: identifier("StaticMiddleware")
        │     ├─inheritanceClause: InheritanceClauseSyntax
        │     │ ├─colon: colon
        │     │ ╰─inheritedTypes: InheritedTypeListSyntax
        │     │   ╰─[0]: InheritedTypeSyntax
        │     │     ╰─type: IdentifierTypeSyntax
        │     │       ╰─name: identifier("StaticMiddlewareProtocol")
        │     ╰─memberBlock: MemberBlockSyntax
        │       ├─leftBrace: leftBrace
        │       ├─members: MemberBlockItemListSyntax
        │       │ ├─[0]: MemberBlockItemSyntax
        │       │ │ ├─decl: FunctionDeclSyntax
        │       │ │ │ ├─attributes: AttributeListSyntax
        │       │ │ │ ├─modifiers: DeclModifierListSyntax
        │       │ │ │ │ ├─[0]: DeclModifierSyntax
        │       │ │ │ │ │ ╰─name: keyword(SwiftSyntax.Keyword.public)
        │       │ │ │ │ ╰─[1]: DeclModifierSyntax
        │       │ │ │ │   ╰─name: keyword(SwiftSyntax.Keyword.static)
        │       │ │ │ ├─funcKeyword: keyword(SwiftSyntax.Keyword.func)
        │       │ │ │ ├─name: identifier("parse")
        │       │ │ │ ├─signature: FunctionSignatureSyntax
        │       │ │ │ │ ├─parameterClause: FunctionParameterClauseSyntax
        │       │ │ │ │ │ ├─leftParen: leftParen
        │       │ │ │ │ │ ├─parameters: FunctionParameterListSyntax
        │       │ │ │ │ │ │ ╰─[0]: FunctionParameterSyntax
        │       │ │ │ │ │ │   ├─attributes: AttributeListSyntax
        │       │ │ │ │ │ │   ├─modifiers: DeclModifierListSyntax
        │       │ │ │ │ │ │   ├─firstName: wildcard
        │       │ │ │ │ │ │   ├─secondName: identifier("function")
        │       │ │ │ │ │ │   ├─colon: colon
        │       │ │ │ │ │ │   ╰─type: IdentifierTypeSyntax
        │       │ │ │ │ │ │     ╰─name: identifier("FunctionCallExprSyntax")
        │       │ │ │ │ │ ╰─rightParen: rightParen
        │       │ │ │ │ ╰─returnClause: ReturnClauseSyntax
        │       │ │ │ │   ├─arrow: arrow
        │       │ │ │ │   ╰─type: IdentifierTypeSyntax
        │       │ │ │ │     ╰─name: keyword(SwiftSyntax.Keyword.Self)
        │       │ │ │ ╰─body: CodeBlockSyntax
        │       │ │ │   ├─leftBrace: leftBrace
        │       │ │ │   ├─statements: CodeBlockItemListSyntax
        │       │ │ │   │ ╰─[0]: CodeBlockItemSyntax
        │       │ │ │   │   ╰─item: ReturnStmtSyntax
        │       │ │ │   │     ├─returnKeyword: keyword(SwiftSyntax.Keyword.return)
        │       │ │ │   │     ╰─expression: FunctionCallExprSyntax
        │       │ │ │   │       ├─calledExpression: DeclReferenceExprSyntax
        │       │ │ │   │       │ ╰─baseName: keyword(SwiftSyntax.Keyword.Self)
        │       │ │ │   │       ├─leftParen: leftParen
        │       │ │ │   │       ├─arguments: LabeledExprListSyntax
        │       │ │ │   │       ├─rightParen: rightParen
        │       │ │ │   │       ╰─additionalTrailingClosures: MultipleTrailingClosureElementListSyntax
        │       │ │ │   ╰─rightBrace: rightBrace
        │       │ │ ╰─semicolon: semicolon MISSING
        │       │ ╰─[1]: MemberBlockItemSyntax
        │       │   ╰─decl: InitializerDeclSyntax
        │       │     ├─attributes: AttributeListSyntax
        │       │     ├─modifiers: DeclModifierListSyntax
        │       │     │ ╰─[0]: DeclModifierSyntax
        │       │     │   ╰─name: keyword(SwiftSyntax.Keyword.public)
        │       │     ├─initKeyword: keyword(SwiftSyntax.Keyword.init)
        │       │     ├─signature: FunctionSignatureSyntax
        │       │     │ ╰─parameterClause: FunctionParameterClauseSyntax
        │       │     │   ├─leftParen: leftParen
        │       │     │   ├─parameters: FunctionParameterListSyntax
        │       │     │   ╰─rightParen: rightParen
        │       │     ╰─body: CodeBlockSyntax
        │       │       ├─leftBrace: leftBrace
        │       │       ├─statements: CodeBlockItemListSyntax
        │       │       ╰─rightBrace: rightBrace
        │       ╰─rightBrace: rightBrace
        ╰─endOfFileToken: endOfFile
        */
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
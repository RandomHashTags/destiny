//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

#if canImport(DestinyBlueprint) && canImport(DestinyUtilities) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import DestinyBlueprint
import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPMessage: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var version:HTTPVersion = .v1_1
        var status = HTTPResponseStatus.notImplemented.code
        var headers:[String:String] = [:]
        var result:RouteResult? = nil
        var contentType:HTTPMediaType? = nil
        var charset:Charset? = nil
        var cookies:[any HTTPCookieProtocol] = [] // TODO: fix
        for child in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            if let key = child.label?.text {
                switch key {
                case "version":
                    version = HTTPVersion.parse(child.expression) ?? version
                case "status":
                    status = HTTPResponseStatus.parse(expr: child.expression)?.code ?? status
                case "headers":
                    headers = HTTPRequestHeader.parse(context: context, child.expression)
                case "result":
                    result = RouteResult(expr: child.expression)
                case "contentType":
                    contentType = HTTPMediaType.parse(context: context, expr: child.expression) ?? contentType
                case "charset":
                    charset = Charset(expr: child.expression)
                default:
                    break
                }
            }
        }
        do {
            var response = try DestinyUtilities.HTTPMessage(version: version, status: status, headers: headers, cookies: cookies, result: result, contentType: contentType, charset: charset).string(escapeLineBreak: true)
            response = "\"" + response + "\""
            return ["\(raw: response)"]
        } catch {
            return []
        }
    }
}
#endif